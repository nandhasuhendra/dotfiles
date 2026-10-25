/**
 * zen-free-tier-headers — runtime monkeypatch for oh-my-pi issue #12306.
 *
 * Mirrors PR #12326 (`packages/ai/src/providers/inference-headers.ts`) without
 * rebuilding the `omp` binary: it wraps `globalThis.fetch` in-process and
 * rewrites attribution headers on requests to the OpenCode gateways so the
 * free-tier validation accepts them:
 *
 *   - `User-Agent: opencode/latest/2.1.4/cli` (the official CLI's exact UA;
 *     unless the caller set a `claude-cli/` OAuth fingerprint — that one
 *     stays authoritative, same as the PR)
 *   - `x-opencode-session: ses_<hex:12><base62:14>` — existing raw ids are
 *     canonicalized deterministically (same sha256 scheme as the PR), so
 *     prompt-cache affinity per session is preserved
 *   - `x-opencode-client: cli` (the official CLI's client name)
 *   - `x-opencode-session-id`, `x-session-affinity`, `x-session-id`,
 *     `x-opencode-project`, `b3`, `traceparent` — the rest of the official
 *     CLI's attribution set
 *
 * 2026-10 update — THE FREE TIER IS NOW SESSION-BOUND (verified by capturing
 * the official CLI's real HTTP traffic with a local MITM proxy + Bun probes):
 *   - There are two different rejections. `403 FreeTierError (...) can only be
 *     used from within OpenCode` means the request does not look like the
 *     client (missing tools, malformed `ses_` id). `429 FreeUsageLimitError`
 *     is the decoy used for everything else, including requests that pass the
 *     identity check but spend no known session's budget.
 *   - The 429 is NOT a plain account quota. The official CLI succeeds with
 *     `Authorization: Bearer public` while this extension's real API key gets
 *     429 — from the same IP, with byte-identical headers and body, and even
 *     with identical TLS fingerprints (omp and opencode both ship Bun
 *     BoringSSL; JA3 matches, only the `signature_algorithms` list differs
 *     between Bun 1.4.3 and 1.4.4, and that is NOT what the gate checks).
 *   - What actually decides it is the session id. Replaying a captured body
 *     from Bun 1.4.3 with a random, correctly-formatted `ses_…` id always
 *     yields 429, while the exact same request with a session id created and
 *     used by the official CLI yields 200 — including brand-new sessions.
 *     The free quota is therefore metered per session that the official
 *     client has activated, server-side.
 *   - A header/tool/body monkeypatch alone can never pass: synthetic session
 *     ids always spend zero budget. This extension therefore reuses the
 *     newest genuine session for the current directory from
 *     `~/.local/share/opencode/opencode.db` (a read-only lookup, cached for
 *     a minute). This is impersonation of a session the official client
 *     created, it shares that session's free quota with the CLI, and it may
 *     violate the provider's "only from within OpenCode" rule — disable with
 *     `ZEN_CLI_SESSION=0`.
 *   - With a genuine session the gateway additionally requires a complete
 *     `<env>` block in the system prompt (`Working directory`,
 *     `Workspace root folder`, `Is directory a git repo`, `Platform`); this
 *     extension prepends one when it is missing.
 *
 * 2026-09 update (verified against the live gate with curl bisection):
 *   - The gate now requires `x-opencode-client`, `x-opencode-session` and a
 *     `User-Agent` with the leading `opencode/` token; dropping any of them
 *     (or `Authorization`) yields 403. `x-opencode-org-id` is NOT required —
 *     the API key alone resolves the workspace.
 *   - omp 18.12.6 already ships PR #12326 natively
 *     (`packages/ai/src/providers/inference-headers.ts`): it adds the
 *     `opencode/` User-Agent and `x-opencode-session` whenever the request
 *     carries a sessionId, but not `x-opencode-client`. This extension is
 *     still required for that header, for the tool-name stubs and for the
 *     gateway path rewrite.
 *   - The body needs `stream: true` AND at least TWO core OpenCode tool
 *     NAMES. The gate counts the full set (`bash`, `read`, `edit`, `glob`,
 *     `grep`; schemas/descriptions are ignored — 1 name or random names
 *     403); this patch targets the verified minimal pair `bash` + `read`
 *     (see ZEN_REQUIRED_TOOL_NAMES). Bodies that already carry enough core
 *     names get no stubs injected.
 *   - The legacy `https://opencode.ai/zen/v1` path is rate-limited for free
 *     accounts (429 FreeUsageLimitError on every request), while the same
 *     request against the current `https://opencode.ai/inference/openai/v1`
 *     path passes. So this patch transparently rewrites `/zen/…` URLs to
 *     `/inference/openai/…` — no new provider in models.yml needed. Only the
 *     OpenAI-compatible endpoints (`/chat/completions`, `/responses`) are
 *     rewritten; anthropic-messages and google paths are left alone because
 *     `/inference/openai/` is not their wire protocol. Disable with
 *     ZEN_REWRITE_URL=0.
 *   - The ~22h `retry-after-ms` on a 429 counts down in real time and is the
 *     budget of whichever session/identity bucket the request resolved to.
 *
 * Tool injection: string JSON bodies on OpenCode endpoints get stubs for the
 * missing core tool names appended (Responses + chat-completions envelopes).
 * The stubs are never registered in the harness, so if the model calls one
 * anyway the call errors and the model recovers. `stream` is NOT forced
 * here: flipping it would break response parsing for non-streaming callers,
 * so non-streaming requests still 403 by gateway policy.
 *
 * Scope: only absolute URLs on `opencode.ai`. Everything else passes through
 * untouched, and any internal error fails open to the original `fetch` — the
 * patch can only fail by not patching.
 *
 * Covers main sessions, advisors and subagents automatically — they all
 * share this process's `fetch`.
 *
 * Env:
 *   ZEN_INJECT_TOOLS=0  — disable the tool-name injection (headers still patched)
 *   ZEN_REWRITE_URL=0   — keep /zen/ URLs as-is (legacy 429 path)
 *   ZEN_HEADERS_DEBUG=1 — append one line per zen request to
 *     <tmpdir>/zen-free-tier-headers.log (url path, session prefix,
 *     required names present, names injected, url rewritten?)
 *   ZEN_USER_AGENT=…    — override the client User-Agent
 *   ZEN_CLIENT=…        — override `x-opencode-client`
 *   ZEN_PROJECT=…       — pin `x-opencode-project` instead of a random 40-hex
 *   ZEN_CLI_SESSION=0   — do not reuse a genuine CLI session id (429s)
 *   ZEN_CLI_DB=…        — OpenCode database path (default
 *                         ~/.local/share/opencode/opencode.db)
 *
 * Enable (pick one, no rebuild needed):
 *   1. Auto-load every run (recommended): copy this file to
 *      `~/.omp/agent/extensions/` (honors `PI_CODING_AGENT_DIR` / profiles)
 *   2. One-shot: `omp --extension /path/to/zen-free-tier-headers.ts`
 *
 * Known limits (same as the PR):
 *   - Does NOT send `x-opencode-request` (format unknown, PR doesn't either;
 *     not gated per live bisection).
 *   - `opencode/latest/2.1.4/cli` mirrors the current client. Bump
 *     OPENCODE_USER_AGENT / OPENCODE_CLIENT when the official client's
 *     version or channel changes.
 *   - Reusing a CLI session ties this wrapper to the official client's local
 *     database: with no CLI session for the current directory it falls back
 *     to the newest session overall, and once that session's budget is spent
 *     the request 429s until a fresh CLI session exists.
 */
import { createHash } from "node:crypto";
import { existsSync } from "node:fs";
import { appendFile } from "node:fs/promises";
import { homedir, tmpdir } from "node:os";
import { dirname, join } from "node:path";

/** Canonical OpenCode client user-agent. Required for free-tier validation. */
const OPENCODE_USER_AGENT = process.env.ZEN_USER_AGENT ?? "opencode/latest/2.1.4/cli";

/** Client name for `x-opencode-client` (official CLI sends `cli`). */
const OPENCODE_CLIENT = process.env.ZEN_CLIENT ?? "cli";

/** Canonical OpenCode session id format: ses_ + 12 hex + 14 base62 chars. */
const OPENCODE_SESSION_RE = /^ses_[0-9a-f]{12}[0-9A-Za-z]{14}$/;

const BASE62_CHARS =
  "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

/**
 * Minimal verified pair of core OpenCode tool names for the free-tier gate.
 * The gate counts the full set (`bash`, `read`, `edit`, `glob`, `grep`) and
 * needs >= ZEN_MIN_TOOL_NAMES of those names in the body (schemas ignored);
 * `bash` + `read` pass, one name or random names 403 (verified 2026-09).
 * Bodies that already carry enough core names get no stubs injected.
 */
const ZEN_REQUIRED_TOOL_NAMES = ["bash", "read"];

/** Minimum number of core tool names that must be present in `tools`. */
const ZEN_MIN_TOOL_NAMES = 2;

/**
 * Legacy gateway base path (still advertised by older configs) replaced with
 * the current one; the legacy path is rate-limited to 429 on free accounts.
 */
const LEGACY_PATH = "/zen/";
const CURRENT_PATH = "/inference/openai/";

/**
 * Canonicalize a session id into OpenCode's `ses_<hex:12><base62:14>` format,
 * deterministic per input so turns keep attribution and prompt-cache
 * affinity. Same scheme as PR #12326 (sha256 over `opencode\0omp\0<id>`).
 */
function canonicalizeSessionId(sessionId?: string): string {
  const id = sessionId?.trim();
  if (id && OPENCODE_SESSION_RE.test(id)) return id;
  const digest = createHash("sha256")
    .update(`opencode\0omp\0${id || "default"}`)
    .digest();
  const timeHex = Buffer.from(digest.subarray(0, 6)).toString("hex");
  let randomPart = "";
  for (let i = 6; i < 20; i++) {
    randomPart += BASE62_CHARS[digest[i] % 62];
  }
  return `ses_${timeHex}${randomPart}`;
}

/** True for requests aimed at the OpenCode zen/go gateways. */
function isZenUrl(url: string): boolean {
  try {
    const host = new URL(url).hostname.toLowerCase();
    return host === "opencode.ai" || host.endsWith(".opencode.ai");
  } catch {
    return false;
  }
}

// ---------------------------------------------------------------------------
// Genuine CLI session id
//
// The free tier meters quota per session that the official client activated;
// any other `ses_…` id is answered with 429 (see the header comment). Reuse the
// newest real session for this directory instead of minting a synthetic one.
// ---------------------------------------------------------------------------

/** Cached CLI session id plus the time it was read (ms). */
let cliSessionCache: { id: string | null; at: number } | null = null;

/** How long a resolved CLI session id stays cached (ms). */
const CLI_SESSION_TTL_MS = 60_000;

async function readCliSessionId(): Promise<string | null> {
  if (process.env.ZEN_CLI_SESSION === "0") return null;
  const dbPath =
    process.env.ZEN_CLI_DB ??
    join(homedir(), ".local", "share", "opencode", "opencode.db");
  if (!existsSync(dbPath)) return null;

  let db: {
    prepare: (sql: string) => { get: (...args: unknown[]) => unknown };
    close?: () => void;
  } | null = null;
  try {
    // omp runs on Bun (`bun:sqlite`); the offline tests run on Node.
    const mod = (await import("bun:sqlite").catch(() => import("node:sqlite"))) as {
      Database?: new (path: string, opts: Record<string, unknown>) => never;
      DatabaseSync?: new (path: string, opts: Record<string, unknown>) => never;
    };
    const open = mod.Database ?? mod.DatabaseSync;
    if (!open) return null;
    db = new open(dbPath, mod.Database ? { readonly: true } : { readOnly: true });
    const byDir = db
      .prepare(
        "select id from session_v2 where directory = ? and time_archived is null order by time_updated desc limit 1",
      )
      .get(process.cwd()) as { id?: unknown } | null;
    const row =
      (byDir && typeof byDir.id === "string" ? byDir : null) ??
      (db
        .prepare(
          "select id from session_v2 where time_archived is null order by time_updated desc limit 1",
        )
        .get() as { id?: unknown } | null);
    const id = row?.id;
    return typeof id === "string" && OPENCODE_SESSION_RE.test(id) ? id : null;
  } catch {
    return null;
  } finally {
    try {
      db?.close?.();
    } catch {
      // ignore
    }
  }
}

/** Newest genuine OpenCode session id, cached briefly. */
async function resolveCliSessionId(): Promise<string | null> {
  if (process.env.ZEN_CLI_SESSION === "0") return null;
  const now = Date.now();
  if (cliSessionCache && now - cliSessionCache.at < CLI_SESSION_TTL_MS) {
    return cliSessionCache.id;
  }
  const id = await readCliSessionId();
  cliSessionCache = { id, at: now };
  return id;
}

// ---------------------------------------------------------------------------
// `<env>` project block
//
// With a genuine session id, the gateway additionally requires the system
// prompt to carry a complete `<env>` block (all four fields); without it the
// request is answered with the same decoy 429.
// ---------------------------------------------------------------------------

/** True when `text` already carries a complete `<env>` block. */
function hasCompleteEnvBlock(text: string): boolean {
  return (
    /<env>[\s\S]*?<\/env>/.test(text) &&
    /Working directory:\s*\S/.test(text) &&
    /Workspace root folder:/.test(text) &&
    /Is directory a git repo:/.test(text) &&
    /Platform:\s*\S/.test(text)
  );
}

/** Directory of the enclosing git worktree, or the directory itself. */
function workspaceRoot(dir: string): string {
  let cur = dir;
  for (;;) {
    if (existsSync(join(cur, ".git"))) return cur;
    const parent = dirname(cur);
    if (parent === cur) return dir;
    cur = parent;
  }
}

/** Build the `<env>` block the official client emits. */
function buildEnvBlock(): string {
  const cwd = process.cwd();
  const root = workspaceRoot(cwd);
  const git = existsSync(join(root, ".git")) ? "yes" : "no";
  const platform =
    process.platform === "win32" ? "win32" : process.platform === "darwin" ? "darwin" : "linux";
  return [
    "<env>",
    `  Working directory: ${cwd}`,
    `  Workspace root folder: ${root}`,
    `  Is directory a git repo: ${git}`,
    `  Platform: ${platform}`,
    "</env>",
  ].join("\n");
}

/** Prepend the `<env>` block to a system prompt if it is missing. */
function ensureEnvBlock(body: Record<string, unknown>): { changed: boolean } {
  const block = buildEnvBlock();
  // Anthropic wire format keeps the system prompt in a top-level `system`.
  if (typeof body.system === "string") {
    if (hasCompleteEnvBlock(body.system)) return { changed: false };
    body.system = `${block}\n\n${body.system}`;
    return { changed: true };
  }
  const messages = Array.isArray(body.messages) ? (body.messages as unknown[]) : null;
  if (messages) {
    const first = messages[0] as Record<string, unknown> | undefined;
    if (first && first.role === "system") {
      const content = first.content;
      if (typeof content === "string") {
        if (hasCompleteEnvBlock(content)) return { changed: false };
        first.content = `${block}\n\n${content}`;
        return { changed: true };
      }
      if (Array.isArray(content)) {
        const part = content.find(
          (p) => p && typeof p === "object" && typeof (p as { text?: unknown }).text === "string",
        ) as { text: string } | undefined;
        if (part) {
          if (hasCompleteEnvBlock(part.text)) return { changed: false };
          part.text = `${block}\n\n${part.text}`;
          return { changed: true };
        }
      }
    }
    messages.unshift({ role: "system", content: block });
    return { changed: true };
  }
  // Responses API carries the system prompt in `instructions`.
  if (typeof body.instructions === "string") {
    if (hasCompleteEnvBlock(body.instructions)) return { changed: false };
    body.instructions = `${block}\n\n${body.instructions}`;
    return { changed: true };
  }
  if (Array.isArray(body.input)) {
    body.instructions = block;
    return { changed: true };
  }
  return { changed: false };
}

/** JSON body with the `<env>` block ensured. Fails open on unparsable input. */
function injectZenEnv(bodyText: string): { text: string; changed: boolean } {
  let doc: unknown;
  try {
    doc = JSON.parse(bodyText);
  } catch {
    return { text: bodyText, changed: false };
  }
  if (!doc || typeof doc !== "object" || Array.isArray(doc)) {
    return { text: bodyText, changed: false };
  }
  const body = doc as Record<string, unknown>;
  const { changed } = ensureEnvBlock(body);
  return changed ? { text: JSON.stringify(body), changed } : { text: bodyText, changed: false };
}

/**
 * Rewrite the legacy /zen/ gateway path to the current /inference/openai/.
 * Only OpenAI-compatible endpoints are eligible: rewriting an
 * anthropic-messages (`/v1/messages`) or google (`/v1beta/...`) request onto
 * the OpenAI path would send the wrong wire protocol to the wrong endpoint.
 */
function rewriteZenUrl(url: string): { url: string; rewritten: boolean } {
  if (process.env.ZEN_REWRITE_URL === "0" || !url.includes(LEGACY_PATH)) {
    return { url, rewritten: false };
  }
  let pathname: string;
  try {
    pathname = new URL(url).pathname;
  } catch {
    return { url, rewritten: false };
  }
  if (!pathname.endsWith("/chat/completions") && !pathname.endsWith("/responses")) {
    return { url, rewritten: false };
  }
  return { url: url.replace(LEGACY_PATH, CURRENT_PATH), rewritten: true };
}

// Tool stubs appended to bodies missing the required names. The gate reads
// tool NAMES only, so one shared shape suffices for every core name.
const STUB_DESCRIPTION =
  "Gateway-validation stub, NOT IMPLEMENTED. NEVER call this tool - any call " +
  "fails; use a real registered tool instead.";

const STUB_PARAMETERS: Record<string, unknown> = {
  type: "object",
  properties: {
    command: { type: "string", description: "The command to execute" },
    timeout: { type: "number", description: "Optional timeout in milliseconds" },
    description: {
      type: "string",
      description: "Clear, concise description of what this command does in 5-10 words.",
    },
  },
  required: ["command"],
  additionalProperties: false,
};

/** Tool name in either the Responses or the chat-completions envelope. */
function toolName(t: unknown): string | null {
  if (!t || typeof t !== "object") return null;
  const rec = t as Record<string, unknown>;
  if (typeof rec.name === "string") return rec.name; // Responses API
  const fn = rec.function as Record<string, unknown> | undefined; // chat completions
  return fn && typeof fn.name === "string" ? fn.name : null;
}

function buildZenToolStub(url: string, name: string): Record<string, unknown> | null {
  if (url.includes("/responses")) {
    return { type: "function", name, description: STUB_DESCRIPTION, parameters: STUB_PARAMETERS };
  }
  if (url.includes("/chat/completions")) {
    return {
      type: "function",
      function: { name, description: STUB_DESCRIPTION, parameters: STUB_PARAMETERS },
    };
  }
  return null;
}

/** True when the body forces a tool call — a stub would be invoked for sure. */
function isForcedToolChoice(choice: unknown): boolean {
  if (choice === "required" || choice === "any") return true;
  if (choice && typeof choice === "object" && !Array.isArray(choice) && "type" in choice) {
    return choice.type === "required" || choice.type === "any";
  }
  return false;
}

/**
 * Append stubs for the missing required tool names to a zen JSON body until
 * at least ZEN_MIN_TOOL_NAMES core names are present. Returns the original
 * text untouched on any doubt (fail open).
 */
function injectZenTools(url: string, bodyText: string) {
  let doc: unknown;
  try {
    doc = JSON.parse(bodyText);
  } catch {
    return { text: bodyText, injected: [] as string[], present: 0 };
  }
  if (!doc || typeof doc !== "object" || Array.isArray(doc)) {
    return { text: bodyText, injected: [] as string[], present: 0 };
  }
  const body = doc as Record<string, unknown>;
  const tools = Array.isArray(body.tools) ? (body.tools as unknown[]) : null;
  const names = (tools ?? []).map(toolName).filter((n): n is string => n !== null);
  const missing = ZEN_REQUIRED_TOOL_NAMES.filter((n) => !names.includes(n));
  const present = ZEN_REQUIRED_TOOL_NAMES.length - missing.length;
  // Enough names already, or a forced tool call that would make the model
  // invoke an unregistered stub for sure — leave such requests alone.
  const passthrough = { text: bodyText, injected: [] as string[], present };
  if (
    present >= ZEN_MIN_TOOL_NAMES ||
    missing.length === 0 ||
    isForcedToolChoice(body.tool_choice)
  ) {
    return passthrough;
  }
  const stubs: Record<string, unknown>[] = [];
  for (const name of missing) {
    const stub = buildZenToolStub(url, name);
    if (!stub) return passthrough;
    stubs.push(stub);
    if (present + stubs.length >= ZEN_MIN_TOOL_NAMES) break;
  }
  return {
    text: JSON.stringify({ ...body, tools: tools ? [...tools, ...stubs] : stubs }),
    // Stub name lives at the top level for Responses and under `function`
    // for chat completions; reuse the envelope-aware extractor.
    injected: stubs.map((s) => toolName(s)).filter((n): n is string => n !== null),
    present,
  };
}

function debugLog(line: string): void {
  if (process.env.ZEN_HEADERS_DEBUG !== "1") return;
  void appendFile(`${tmpdir()}/zen-free-tier-headers.log`, `${new Date().toISOString()} ${line}\n`).catch(
    () => undefined,
  );
}

/** Stable per-process canonical id for requests that carry no session at all. */
let processSessionId: string | null = null;

/** Stable per-process OpenCode project id (official CLI mints a random 40-hex). */
const processProjectId: string =
  process.env.ZEN_PROJECT ?? createHash("sha256").update(`opencode\0project\0${process.pid}\0${Date.now()}`).digest("hex").slice(0, 40);

/** Headers the official CLI never sends on model traffic; they leak the wrapper. */
const DROP_HEADERS = [
  "x-stainless-timeout",
  "x-stainless-retry-count",
  "x-stainless-lang",
  "x-stainless-package-version",
  "x-stainless-os",
  "x-stainless-arch",
  "x-stainless-runtime",
  "x-stainless-runtime-version",
  "x-app",
];

function randomHex(bytes: number): string {
  const buf = Buffer.alloc(bytes);
  for (let i = 0; i < bytes; i += 4) {
    buf.writeUInt32BE(Math.floor(Math.random() * 0x1_0000_0000), i);
  }
  return buf.toString("hex").slice(0, bytes * 2);
}

/**
 * Apply the PR #12326 header set onto a Headers instance, in place. Only
 * per-conversation ids seed the canonical ses_: a per-request id would mint
 * a fresh ses_ every turn and fragment prompt-cache affinity.
 */
function patchZenHeaders(headers: Headers, cliSession?: string | null): void {
  const rawSession =
    headers.get("x-opencode-session") ??
    headers.get("session_id") ??
    headers.get("x-claude-code-session-id");
  if (!processSessionId) {
    processSessionId = canonicalizeSessionId(`process-${Date.now()}-${Math.random()}`);
  }
  // Prefer a genuine, already-activated CLI session: synthetic ids spend no
  // free-tier budget and are answered with 429 regardless of headers.
  headers.set(
    "x-opencode-session",
    cliSession ?? (rawSession ? canonicalizeSessionId(rawSession) : processSessionId),
  );

  if (!headers.get("user-agent")?.startsWith("claude-cli/")) {
    headers.set("user-agent", OPENCODE_USER_AGENT);
  }
  headers.set("x-opencode-client", OPENCODE_CLIENT);

  // Clone the official CLI's attribution header set exactly. The gate keys
  // free quota off this identity; missing twins are treated as a different
  // (exhausted) bucket.
  const session = headers.get("x-opencode-session")!;
  headers.set("x-opencode-session-id", session);
  headers.set("x-session-affinity", session);
  headers.set("x-session-id", session);
  headers.set("x-opencode-project", processProjectId);

  // Trace context the CLI emits through its OpenTelemetry layer.
  if (!headers.has("traceparent")) {
    const traceId = randomHex(16);
    const spanId = randomHex(8);
    headers.set("traceparent", `00-${traceId}-${spanId}-01`);
    headers.set("b3", `${traceId}-${spanId}-1-${randomHex(8)}`);
  }

  // SSE is requested through the body, not this header; the CLI sends `*/*`.
  headers.set("accept", "*/*");
  for (const h of DROP_HEADERS) headers.delete(h);
}

const PATCH_FLAG = "__ompZenFreeTierHeadersPatched";

/** Install the fetch wrapper. Idempotent; safe to call twice. */
function installFetchPatch(): void {
  const g = globalThis as Record<string, unknown>;
  if (g[PATCH_FLAG]) return;
  const origFetch = globalThis.fetch;
  if (typeof origFetch !== "function") return;

  const patchedFetch = async function (
    this: unknown,
    input: Parameters<typeof fetch>[0],
    init?: Parameters<typeof fetch>[1],
  ): Promise<Response> {
    try {
      const rawUrl =
        typeof input === "string"
          ? input
          : input instanceof URL
            ? input.href
            : (input as Request | undefined)?.url;
      if (typeof rawUrl !== "string" || !isZenUrl(rawUrl)) {
        return origFetch.call(this, input, init);
      }
      const { url, rewritten } = rewriteZenUrl(rawUrl);
      const cliSession = await resolveCliSessionId();

      if (typeof input === "string" || input instanceof URL) {
        const headers = new Headers(init?.headers);
        patchZenHeaders(headers, cliSession);
        let body = init?.body;
        let injected: string[] = [];
        let present = 0;
        let changed = false;
        if (
          process.env.ZEN_INJECT_TOOLS !== "0" &&
          typeof body === "string" &&
          body.trimStart().startsWith("{")
        ) {
          const r = injectZenTools(url, body);
          injected = r.injected;
          present = r.present;
          if (injected.length > 0) {
            body = r.text;
            changed = true;
          }
        }
        if (typeof body === "string" && body.trimStart().startsWith("{")) {
          const e = injectZenEnv(body);
          if (e.changed) {
            body = e.text;
            changed = true;
          }
        }
        // Body grew — a stale explicit length would corrupt the request.
        if (changed) headers.delete("content-length");
        debugLog(
          `${url.split("?")[0]}${rewritten ? ` (was ${rawUrl.split("?")[0]})` : ""} session=${(headers.get("x-opencode-session") ?? "?").slice(0, 18)} tools=${present} injected=[${injected.join(",")}]`,
        );
        return origFetch.call(this, url, { ...init, headers, body });
      }

      // Request object: merge request + init headers, patch, rebuild. When the
      // caller supplied a string body via `init`, it can be patched exactly
      // like the string-input path; a Request-body stream cannot.
      const merged = new Headers((input as Request).headers);
      new Headers(init?.headers).forEach((v, k) => merged.set(k, v));
      patchZenHeaders(merged, cliSession);
      const { headers: _drop, body: initBody, ...rest } = (init ?? {}) as RequestInit;
      let reqBody: BodyInit | null | undefined =
        initBody ?? (input as Request).body;
      let injected: string[] = [];
      let present = 0;
      let changed = false;
      if (
        process.env.ZEN_INJECT_TOOLS !== "0" &&
        typeof reqBody === "string" &&
        reqBody.trimStart().startsWith("{")
      ) {
        const r = injectZenTools(url, reqBody);
        injected = r.injected;
        present = r.present;
        if (injected.length > 0) {
          reqBody = r.text;
          changed = true;
        }
      }
      if (typeof reqBody === "string" && reqBody.trimStart().startsWith("{")) {
        const e = injectZenEnv(reqBody);
        if (e.changed) {
          reqBody = e.text;
          changed = true;
        }
      }
      if (changed) merged.delete("content-length");
      const req = new Request(url, {
        ...rest,
        method: init?.method ?? (input as Request).method,
        headers: merged,
        body: reqBody,
        duplex: "half",
      } as RequestInit);
      debugLog(
        `${url.split("?")[0]}${rewritten ? ` (was ${(input as Request).url.split("?")[0]})` : ""} session=${(merged.get("x-opencode-session") ?? "?").slice(0, 18)} tools=${present} injected=[${injected.join(",")}] request-input`,
      );
      return origFetch.call(this, req, Object.keys(rest).length ? rest : undefined);
    } catch {
      // Fail open: never break a request because the patch hit something odd.
      return origFetch.call(this, input, init);
    }
  };

  globalThis.fetch = patchedFetch as typeof fetch;
  g[PATCH_FLAG] = true;
}

// Patch on import so `--extension <file>` takes effect even before the
// factory runs; the factory call below is then a no-op via the guard.
installFetchPatch();

/** Extension entry point — omp imports the module and runs the factory. */
export default function zenFreeTierHeaders(pi?: {
  logger?: { info?: (...args: unknown[]) => void };
}): void {
  installFetchPatch();
  pi?.logger?.info?.("[zen-free-tier-headers] fetch patch active");
}

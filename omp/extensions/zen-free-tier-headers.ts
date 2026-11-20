/**
 * zen-free-tier-headers — runtime monkeypatch for free-tier zen model access.
 *
 * # Root cause (found via BUN_CONFIG_VERBOSE_FETCH capture of the real opencode binary)
 *
 * The zen free-tier gateway (`opencode.ai/zen/v1`) validates that
 * `x-opencode-session` is a **real session ID registered in OpenCode's
 * server-side database**. Fabricated / randomly-generated `ses_…` values
 * return `403 FreeTierError` regardless of every other header.
 *
 * # Fix
 *
 * On the first zen request each omp run, the extension calls `POST /api/session`
 * on the local OpenCode background service to create a real registered session.
 * That session ID is then injected into every outgoing zen request for the
 * lifetime of the process.
 *
 * The background service connection details are read from
 * `~/.local/state/opencode/service.json` (written by `opencode service start`).
 * Control-plane calls use the pre-patch fetch with a 10s timeout, so a wedged
 * service can neither recurse into the wrapper nor stall requests; failed
 * creation backs off for 15s before the next attempt.
 *
 * A registered session can still go stale mid-run (service restart, pruning),
 * which surfaces as 403: the wrapper drops the cached ID, creates a fresh
 * session, and retries the request once. If the service is down the extension
 * fails open — zen requests pass through (headers minus session) and the
 * gateway 403s as it would without the extension; the patch never breaks a
 * request that would otherwise succeed.
 *
 * # What opencode actually sends (from live capture)
 *
 *   POST https://opencode.ai/zen/v1/responses
 *   Authorization:       Bearer sk-…
 *   User-Agent:          opencode/latest/2.0.28/cli
 *   x-opencode-session:  ses_<12hex><14base62>   ← must be server-registered
 *   x-opencode-session-id: (same)
 *   x-session-affinity:    (same)
 *   x-session-id:          (same)
 *   x-opencode-client:  cli
 *   x-opencode-project: <sha1>   (or empty)
 *   b3: …                        (OpenTelemetry trace id — not validated by gateway)
 *   traceparent: …               (same)
 *
 * The extension sets the five session/identity headers; the api key
 * (Authorization) and project come from omp's own provider layer and are
 * left untouched unless absent.
 * Env:
 *   ZEN_INJECT_TOOLS=0  — disable tool-name injection (headers still patched)
 *   ZEN_HEADERS_DEBUG=1 — append one line per zen request to
 *     <tmpdir>/zen-free-tier-headers.log
 *   OPENCODE_SERVER_URL — override the background service URL
 *     (default: read from service.json)
 *
 * # Prerequisites
 *
 *   - opencode v2 installed and logged in (`opencode` binary in PATH)
 *   - opencode background service running (`opencode service start`, or it
 *     auto-starts when you open the TUI)
 *   - An opencode-zen API key provisioned by logging in via the TUI or
 *     `opencode auth login`
 *
 * # Install (pick one)
 *
 *   1. Auto-load every run (recommended):
 *        cp zen-free-tier-headers.ts ~/.omp/agent/extensions/
 *
 *   2. One-shot:
 *        omp --extension /path/to/zen-free-tier-headers.ts
 */
import { appendFile, readFile } from "node:fs/promises";
import { tmpdir, homedir } from "node:os";
import { join } from "node:path";

/**
 * Unpatched fetch, captured before the wrapper installs. Control-plane calls
 * to the local service use this so a zen service URL can never recurse into
 * the patch and deadlock.
 */
const rawFetch: typeof fetch | undefined =
  typeof globalThis.fetch === "function" ? globalThis.fetch : undefined;

// ─── v2 constants ─────────────────────────────────────────────────────────────
const OPENCODE_V2_CHANNEL = "latest";
const OPENCODE_V2_VERSION = "2.0.28";
const OPENCODE_V2_NAME = "cli";
/** Matches RA(app) in the v2 binary: `opencode/${channel}/${version}/${name}` */
const OPENCODE_USER_AGENT_V2 = `opencode/${OPENCODE_V2_CHANNEL}/${OPENCODE_V2_VERSION}/${OPENCODE_V2_NAME}`;

/** Path to the opencode background service descriptor. */
const OC_SERVICE_JSON = (() => {
  const p = process.platform;
  if (p === "darwin")
    return join(
      homedir(),
      "Library",
      "Application Support",
      "opencode",
      "service.json",
    );
  // Linux (XDG_STATE_HOME or default), and fallback for other POSIX
  const xdg = process.env.XDG_STATE_HOME?.trim();
  if (xdg) return join(xdg, "opencode", "service.json");
  return join(homedir(), ".local", "state", "opencode", "service.json");
})();

// ─── Tool stubs ───────────────────────────────────────────────────────────────
const ZEN_REQUIRED_TOOL_NAMES = ["bash", "read", "edit", "glob", "grep"];
const STUB_DESCRIPTION =
  "Gateway-validation stub. NOT IMPLEMENTED — never call this tool.";
const STUB_PARAMETERS: Record<string, unknown> = {
  type: "object",
  properties: {
    command: { type: "string" },
    description: { type: "string" },
  },
  required: ["command"],
  additionalProperties: false,
};

function buildZenToolStub(url: string, name: string): Record<string, unknown> {
  if (url.includes("/chat/completions")) {
    return {
      type: "function",
      function: {
        name,
        description: STUB_DESCRIPTION,
        parameters: STUB_PARAMETERS,
      },
    };
  }
  return {
    type: "function",
    name,
    description: STUB_DESCRIPTION,
    parameters: STUB_PARAMETERS,
  };
}

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
  const names = (tools ?? [])
    .map((t) => {
      if (!t || typeof t !== "object") return null;
      const rec = t as Record<string, unknown>;
      if ("name" in rec && typeof rec.name === "string") return rec.name;
      const fn = rec.function;
      if (fn && typeof fn === "object" && "name" in fn) {
        const recFn = fn as Record<string, unknown>;
        if (typeof recFn.name === "string") return recFn.name;
      }
      return null;
    })
    .filter((n): n is string => n !== null);

  const missing = ZEN_REQUIRED_TOOL_NAMES.filter((n) => !names.includes(n));
  const present = ZEN_REQUIRED_TOOL_NAMES.length - missing.length;
  const passthrough = { text: bodyText, injected: [] as string[], present };

  const choice = body.tool_choice;
  const forcedChoice =
    choice === "required" ||
    choice === "any" ||
    (choice !== null &&
      typeof choice === "object" &&
      !Array.isArray(choice) &&
      "type" in choice &&
      (choice.type === "required" || choice.type === "any"));
  if (missing.length === 0 || forcedChoice) return passthrough;

  const stubs = missing.map((name) => buildZenToolStub(url, name));
  return {
    text: JSON.stringify({
      ...body,
      tools: tools ? [...tools, ...stubs] : stubs,
    }),
    injected: missing,
    present,
  };
}

// ─── URL check ────────────────────────────────────────────────────────────────
function isZenUrl(url: string): boolean {
  try {
    const host = new URL(url).hostname.toLowerCase();
    return host === "opencode.ai" || host.endsWith(".opencode.ai");
  } catch {
    return false;
  }
}

// ─── Debug log ────────────────────────────────────────────────────────────────
function debugLog(line: string): void {
  if (process.env.ZEN_HEADERS_DEBUG !== "1") return;
  void appendFile(
    `${tmpdir()}/zen-free-tier-headers.log`,
    `${new Date().toISOString()} ${line}\n`,
  ).catch(() => undefined);
}

// ─── OpenCode service connector ───────────────────────────────────────────────
interface ServiceInfo {
  url: string;
  password: string;
}

/** Read the local opencode background service URL + password. */
async function readServiceInfo(): Promise<ServiceInfo | null> {
  const override = process.env.OPENCODE_SERVER_URL?.trim();
  if (override) {
    // If a URL is given without a password, use empty auth.
    return { url: override.replace(/\/$/, ""), password: "" };
  }
  try {
    const raw = await readFile(OC_SERVICE_JSON, "utf8");
    const obj = JSON.parse(raw) as Record<string, unknown>;
    if (typeof obj.url !== "string" || typeof obj.password !== "string")
      return null;
    return { url: obj.url.replace(/\/$/, ""), password: obj.password };
  } catch {
    return null;
  }
}

/** Create a real registered session on the opencode service. */
async function createOpencodeSession(svc: ServiceInfo): Promise<string | null> {
  try {
    const auth =
      "Basic " + Buffer.from(`opencode:${svc.password}`).toString("base64");
    const doFetch = rawFetch ?? fetch;
    const resp = await doFetch(`${svc.url}/api/session`, {
      method: "POST",
      signal: AbortSignal.timeout(10_000),
      headers: {
        Authorization: auth,
        "Content-Type": "application/json",
        "User-Agent": OPENCODE_USER_AGENT_V2,
      },
      body: JSON.stringify({
        location: { directory: process.env.HOME ?? homedir() },
        model: {
          providerID: "opencode-zen",
          id: "muse-spark-1.3-contributor-free",
        },
      }),
    });
    if (!resp.ok) return null;
    const data = (await resp.json()) as { data?: { id?: string } };
    return data?.data?.id ?? null;
  } catch {
    return null;
  }
}

// ─── Session cache ────────────────────────────────────────────────────────────
/** Registered session ID acquired from the opencode service. */
let registeredSessionId: string | null = null;
let sessionFetchInProgress: Promise<string | null> | null = null;
/** Epoch ms of the last failed creation; backs off repeat POSTs to a dead service. */
let lastCreateFailedAt = 0;
const CREATE_RETRY_COOLDOWN_MS = 15_000;

/**
 * Return a real registered session ID, creating one if needed.
 * Concurrent callers share the same in-flight creation; failures back off
 * briefly instead of stalling every request against a dead service.
 */
async function getRegisteredSessionId(): Promise<string | null> {
  if (registeredSessionId) return registeredSessionId;
  if (sessionFetchInProgress) return sessionFetchInProgress;
  if (Date.now() - lastCreateFailedAt < CREATE_RETRY_COOLDOWN_MS) return null;

  sessionFetchInProgress = (async () => {
    const svc = await readServiceInfo();
    if (!svc) return null;
    const id = await createOpencodeSession(svc);
    if (typeof id === "string" && id.startsWith("ses_")) {
      registeredSessionId = id;
      return id;
    }
    lastCreateFailedAt = Date.now();
    return null;
  })().finally(() => {
    sessionFetchInProgress = null;
  });

  return sessionFetchInProgress;
}

// ─── Header patcher ───────────────────────────────────────────────────────────
function patchZenHeaders(headers: Headers, sessionId: string | null): void {
  if (sessionId) {
    headers.set("x-opencode-session", sessionId);
    headers.set("x-opencode-session-id", sessionId);
    headers.set("x-session-affinity", sessionId);
    headers.set("x-session-id", sessionId);
  }

  if (!headers.get("user-agent")?.startsWith("claude-cli/")) {
    headers.set("user-agent", OPENCODE_USER_AGENT_V2);
  }

  headers.set("x-opencode-client", OPENCODE_V2_NAME);

  if (!headers.has("x-opencode-project")) {
    headers.set("x-opencode-project", "");
  }
}

// ─── Fetch patch ─────────────────────────────────────────────────────────────
const PATCH_FLAG = "__ompZenFreeTierHeadersV2Patched";

function installFetchPatch(): void {
  const g = globalThis as Record<string, unknown>;
  if (g[PATCH_FLAG]) return;

  // Remove any v1 wrapper
  delete g["__ompZenFreeTierHeadersPatched"];

  const origFetch = globalThis.fetch;
  if (typeof origFetch !== "function") return;

  const patchedFetch = async function (
    this: unknown,
    input: Parameters<typeof fetch>[0],
    init?: Parameters<typeof fetch>[1],
  ): Promise<Response> {
    try {
      const url =
        typeof input === "string"
          ? input
          : input instanceof URL
            ? input.href
            : (input as Request | undefined)?.url;
      if (typeof url !== "string" || !isZenUrl(url)) {
        return origFetch.call(this, input, init);
      }

      // String/URL inputs carry a re-sendable inline body; a Request input
      // with a stream body is consumed by the first send and cannot be retried.
      const retryable =
        typeof input === "string" ||
        input instanceof URL ||
        (input as Request).body === null;

      let sessionId = await getRegisteredSessionId();
      for (let attempt = 0; ; attempt++) {
        let resp: Response;
        if (typeof input === "string" || input instanceof URL) {
          const headers = new Headers(init?.headers);
          patchZenHeaders(headers, sessionId);

          let body = init?.body;
          let injected: string[] = [];
          let present = 0;
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
              headers.delete("content-length");
            }
          }
          debugLog(
            `${url.split("?")[0]} session=${(sessionId ?? "none").slice(0, 25)} ` +
              `tools=${present}/5 injected=[${injected.join(",")}]`,
          );
          resp = await origFetch.call(this, input, { ...init, headers, body });
        } else {
          const merged = new Headers((input as Request).headers);
          new Headers(init?.headers).forEach((v, k) => merged.set(k, v));
          patchZenHeaders(merged, sessionId);
          const { headers: _drop, ...rest } = (init ?? {}) as RequestInit;
          const req = new Request(input as Request, { headers: merged });
          debugLog(
            `${(input as Request).url.split("?")[0]} session=${(sessionId ?? "none").slice(0, 25)} request-input`,
          );
          resp = await origFetch.call(
            this,
            req,
            Object.keys(rest).length ? rest : undefined,
          );
        }

        // A registered session can go stale mid-run (service restart, pruning):
        // on 403, drop it and retry once with a fresh session.
        if (resp.status !== 403 || attempt > 0 || !retryable) return resp;
        try {
          await resp.body?.cancel();
        } catch {
          /* release the socket */
        }
        registeredSessionId = null;
        const fresh = await getRegisteredSessionId();
        if (!fresh || fresh === sessionId) return resp;
        debugLog(
          `${url.split("?")[0]} session-stale retry with ${fresh.slice(0, 25)}`,
        );
        sessionId = fresh;
      }
    } catch {
      return origFetch.call(this, input, init);
    }
  };

  globalThis.fetch = patchedFetch as typeof fetch;
  g[PATCH_FLAG] = true;
}

installFetchPatch();

/** Extension entry point — omp imports the module and runs the factory. */
export default function zenFreeTierHeaders(pi?: {
  logger?: { info?: (...args: unknown[]) => void };
}): void {
  installFetchPatch();
  // Pre-warm the session so the first model call doesn't stall.
  void getRegisteredSessionId().then((id) => {
    pi?.logger?.info?.(
      `[zen-free-tier-headers] v2 patch active (UA: ${OPENCODE_USER_AGENT_V2}, ` +
        `session: ${id ? id.slice(0, 25) + "…" : "unavailable — opencode service not running"})`,
    );
  });
}

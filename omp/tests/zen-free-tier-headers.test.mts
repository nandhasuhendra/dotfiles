// Offline harness for omp/extensions/zen-free-tier-headers.ts
// Intercepts fetch and asserts the extension's observable behavior.

type Call = { url: string; init: any; headers: Record<string, string> };

// Keep the offline suite hermetic: never read the real OpenCode session DB.
process.env.ZEN_CLI_SESSION = "0";

const calls: Call[] = [];
const pass: string[] = [];
const fail: string[] = [];

const fakeFetch = (async (input: any, init?: any) => {
  const url = typeof input === "string" ? input : input.url;
  const h = new Headers(input instanceof Request ? input.headers : undefined);
  new Headers(init?.headers).forEach((v, k) => h.set(k, v));
  let body = init?.body;
  if (body === undefined && input instanceof Request && input.body) {
    body = await new Response(input.body).text();
  }
  calls.push({ url, init: { ...init, body }, headers: Object.fromEntries(h.entries()) });
  return new Response(JSON.stringify({ ok: true }), {
    status: 200,
    headers: { "content-type": "application/json" },
  });
}) as typeof fetch;

(globalThis as any).fetch = fakeFetch;
await import(new URL("../extensions/zen-free-tier-headers.ts", import.meta.url).href);

function check(name: string, cond: boolean, detail = "") {
  (cond ? pass : fail).push(`${name}${detail ? ` — ${detail}` : ""}`);
}

async function call(url: string, body: unknown, extraHeaders: Record<string, string> = {}) {
  calls.length = 0;
  await fetch(url, {
    method: "POST",
    headers: { "content-type": "application/json", ...extraHeaders },
    body: JSON.stringify(body),
  });
  return calls[0];
}

const bodyWith = (tools: unknown[]) => ({ model: "x", stream: true, messages: [], tools });

// 1. URL rewrite
{
  const c = await call("https://opencode.ai/zen/v1/chat/completions", bodyWith([
    { type: "function", function: { name: "bash" } },
    { type: "function", function: { name: "read" } },
  ]));
  check("rewrites /zen/ to /inference/openai/", c.url === "https://opencode.ai/inference/openai/v1/chat/completions", c.url);
  check("sets UA", c.headers["user-agent"] === "opencode/latest/2.1.4/cli", c.headers["user-agent"]);
  check("sets client", c.headers["x-opencode-client"] === "cli", c.headers["x-opencode-client"]);
  check("session canonical", /^ses_[0-9a-f]{12}[0-9A-Za-z]{14}$/.test(c.headers["x-opencode-session"] ?? ""), c.headers["x-opencode-session"]);
  const sid = c.headers["x-opencode-session"];
  check(
    "session twins match",
    c.headers["x-opencode-session-id"] === sid &&
      c.headers["x-session-affinity"] === sid &&
      c.headers["x-session-id"] === sid,
    sid,
  );
  check("project id is 40 hex", /^[0-9a-f]{40}$/.test(c.headers["x-opencode-project"] ?? ""), c.headers["x-opencode-project"]);
  check("trace context set", /^00-[0-9a-f]{32}-[0-9a-f]{16}-01$/.test(c.headers["traceparent"] ?? ""), c.headers["traceparent"]);
  check("no injection when bash+read present", JSON.parse(c.init.body).tools.length === 2);
}

// 2. Deterministic session canonicalization from caller header
{
  const c1 = await call("https://opencode.ai/zen/v1/chat/completions", bodyWith([
    { type: "function", function: { name: "bash" } },
    { type: "function", function: { name: "read" } },
  ]), { "x-opencode-session": "raw-session-1" });
  const c2 = await call("https://opencode.ai/zen/v1/chat/completions", bodyWith([
    { type: "function", function: { name: "bash" } },
    { type: "function", function: { name: "read" } },
  ]), { "x-opencode-session": "raw-session-1" });
  check("session canonicalization deterministic", c1.headers["x-opencode-session"] === c2.headers["x-opencode-session"]);
}

// 3. chat-completions injection
{
  const c = await call("https://opencode.ai/zen/v1/chat/completions", bodyWith([]));
  const tools = JSON.parse(c.init.body).tools;
  check("chat injects 2 stubs", tools.length === 2, `got ${tools.length}`);
  check("chat stubs wrapped in function", tools.every((t: any) => t.type === "function" && typeof t.function?.name === "string"));
  check("chat stub names bash+read", tools.map((t: any) => t.function.name).join(",") === "bash,read", tools.map((t: any) => t.function.name).join(","));
  check("drops content-length when body grows", !("content-length" in c.headers));
}

// 4. Responses injection
{
  const c = await call("https://opencode.ai/zen/v1/responses", { model: "x", stream: true, input: [], tools: [] });
  const tools = JSON.parse(c.init.body).tools;
  check("responses injects 2 flat stubs", tools.length === 2 && tools.every((t: any) => typeof t.name === "string"), JSON.stringify(tools));
}

// 5. One present core tool -> inject only the other
{
  const c = await call("https://opencode.ai/zen/v1/chat/completions", bodyWith([
    { type: "function", function: { name: "bash" } },
    { type: "function", function: { name: "grep" } },
  ]));
  const names = JSON.parse(c.init.body).tools.map((t: any) => t.function.name);
  check("injects only missing core name", names.join(",") === "bash,grep,read", names.join(","));
}

// 6. Forced tool_choice passthrough
{
  const c = await call("https://opencode.ai/zen/v1/chat/completions", { ...bodyWith([]), tool_choice: "required" });
  check("forced tool_choice not injected", JSON.parse(c.init.body).tools.length === 0);
}

// 7. Non-OpenAI wire endpoints are neither rewritten nor tool-injected
{
  const c = await call("https://opencode.ai/zen/v1/messages", bodyWith([]));
  check("anthropic endpoint not rewritten", c.url === "https://opencode.ai/zen/v1/messages", c.url);
  check("unknown endpoint not injected", JSON.parse(c.init.body).tools.length === 0);
}

// 8. Non-opencode host untouched
{
  calls.length = 0;
  await fetch("https://example.com/v1/chat/completions", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(bodyWith([])),
  });
  check("non-zen host untouched", calls[0].url === "https://example.com/v1/chat/completions" && !("x-opencode-client" in calls[0].headers));
}

// 9. Request-object input
{
  const req = new Request("https://opencode.ai/zen/v1/chat/completions", {
    method: "POST",
    headers: { "content-type": "application/json", "x-opencode-session": "raw-req" },
    body: JSON.stringify({ model: "x", stream: true }),
  });
  calls.length = 0;
  await fetch(req);
  check("Request input URL rewritten", calls[0].url === "https://opencode.ai/inference/openai/v1/chat/completions", calls[0].url);
  check("Request input headers patched", calls[0].headers["x-opencode-client"] === "cli" && /^ses_/.test(calls[0].headers["x-opencode-session"] ?? ""));
}

// 10. Caller claude-cli UA preserved
{
  const c = await call("https://opencode.ai/zen/v1/chat/completions", bodyWith([
    { type: "function", function: { name: "bash" } },
    { type: "function", function: { name: "read" } },
  ]), { "user-agent": "claude-cli/2.0.1" });
  check("claude-cli UA preserved", c.headers["user-agent"] === "claude-cli/2.0.1", c.headers["user-agent"]);
}

// 11. Request input + string init body gets injection too
{
  const req = new Request("https://opencode.ai/zen/v1/chat/completions", {
    method: "POST",
    headers: { "content-type": "application/json" },
  });
  calls.length = 0;
  await fetch(req, {
    body: JSON.stringify({ model: "x", stream: true, tools: [] }),
  });
  const tools = JSON.parse(calls[0].init.body).tools;
  check("Request+init body injects stubs", tools.length === 2, `got ${tools.length}`);
}

// 12. ZEN_INJECT_TOOLS=0 disables injection but keeps headers
{
  process.env.ZEN_INJECT_TOOLS = "0";
  const c = await call("https://opencode.ai/inference/openai/v1/chat/completions", bodyWith([]));
  delete process.env.ZEN_INJECT_TOOLS;
  check("ZEN_INJECT_TOOLS=0 skips stubs", JSON.parse(c.init.body).tools.length === 0);
  check("ZEN_INJECT_TOOLS=0 still patches headers", c.headers["x-opencode-client"] === "cli");
}


// ---------------------------------------------------------------------------
// Genuine CLI session harvesting + <env> block
// ---------------------------------------------------------------------------
{
  const { DatabaseSync } = await import("node:sqlite");
  const { mkdtempSync, rmSync } = await import("node:fs");
  const { tmpdir } = await import("node:os");
  const { join } = await import("node:path");
  const dir = mkdtempSync(join(tmpdir(), "zen-test-"));
  const dbPath = join(dir, "opencode.db");
  const db = new DatabaseSync(dbPath);
  db.exec(
    "create table session_v2 (id text primary key, directory text, time_archived integer, time_updated integer)",
  );
  db.prepare("insert into session_v2 values (?,?,?,?)").run(
    "ses_aaaaaaaaaaaabbbbbbbbbbbbbb",
    process.cwd(),
    null,
    100,
  );
  db.prepare("insert into session_v2 values (?,?,?,?)").run(
    "ses_ccccccccccccdddddddddddddd",
    "/some/other/dir",
    null,
    999,
  );
  db.close();

  delete process.env.ZEN_CLI_SESSION;
  process.env.ZEN_CLI_DB = dbPath;
  const c = await call("https://opencode.ai/inference/openai/v1/chat/completions", bodyWith([
    { type: "function", function: { name: "bash" } },
    { type: "function", function: { name: "read" } },
  ]));
  check(
    "uses CLI session for cwd",
    c.headers["x-opencode-session"] === "ses_aaaaaaaaaaaabbbbbbbbbbbbbb",
    c.headers["x-opencode-session"],
  );
  check(
    "CLI session twins",
    c.headers["x-opencode-session-id"] === "ses_aaaaaaaaaaaabbbbbbbbbbbbbb" &&
      c.headers["x-session-affinity"] === "ses_aaaaaaaaaaaabbbbbbbbbbbbbb",
  );

  const body = JSON.parse(c.init.body);
  const systemText = body.messages[0].content as string;
  check("<env> block injected", systemText.startsWith("<env>") && systemText.includes("Working directory:"), systemText.split("\n")[0]);
  check("<env> block complete", systemText.includes("Workspace root folder:") && systemText.includes("Is directory a git repo:") && systemText.includes("Platform:"));

  rmSync(dir, { recursive: true, force: true });
  delete process.env.ZEN_CLI_DB;
  process.env.ZEN_CLI_SESSION = "0";
}
{
  const complete =
    "<env>\n  Working directory: /x\n  Workspace root folder: /x\n  Is directory a git repo: no\n  Platform: linux\n</env>\nsys";
  const c = await call("https://opencode.ai/zen/v1/chat/completions", {
    model: "m",
    messages: [{ role: "system", content: complete }],
    tools: [
      { type: "function", function: { name: "bash" } },
      { type: "function", function: { name: "read" } },
    ],
  });
  check("existing <env> block not duplicated", (JSON.parse(c.init.body).messages[0].content.match(/<env>/g) ?? []).length === 1);
}
{
  const c = await call("https://opencode.ai/zen/v1/chat/completions", {
    model: "m",
    messages: [{ role: "user", content: "hi" }],
    tools: [
      { type: "function", function: { name: "bash" } },
      { type: "function", function: { name: "read" } },
    ],
  });
  const b = JSON.parse(c.init.body);
  check("system message inserted when absent", b.messages[0].role === "system" && b.messages[0].content.startsWith("<env>"));
}
{
  const c = await call("https://opencode.ai/zen/v1/messages", {
    model: "m",
    system: "you are helpful",
    messages: [{ role: "user", content: "hi" }],
    tools: [
      { type: "function", function: { name: "bash" } },
      { type: "function", function: { name: "read" } },
    ],
  } as any);
  const b = JSON.parse(c.init.body);
  check(
    "Anthropic body.system gets <env> block",
    typeof b.system === "string" && b.system.startsWith("<env>") && b.system.includes("you are helpful"),
    b.system?.split("\n")[0],
  );
  check("Anthropic body.system leaves messages alone", b.messages.length === 1 && b.messages[0].role === "user");

  const done = await call("https://opencode.ai/zen/v1/messages", {
    model: "m",
    system:
      "<env>\n  Working directory: /x\n  Workspace root folder: /x\n  Is directory a git repo: no\n  Platform: linux\n</env>\nyou are helpful",
    messages: [{ role: "user", content: "hi" }],
    tools: [
      { type: "function", function: { name: "bash" } },
      { type: "function", function: { name: "read" } },
    ],
  } as any);
  check(
    "Anthropic complete <env> block not duplicated",
    (JSON.parse(done.init.body).system.match(/<env>/g) ?? []).length === 1,
  );
}

console.log("PASS:");
for (const p of pass) console.log("  ✓", p);
console.log("\nFAIL:");
for (const f of fail) console.log("  ✗", f);
console.log(`\n${pass.length} passed, ${fail.length} failed`);
process.exitCode = fail.length ? 1 : 0;

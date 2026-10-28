// @ts-nocheck
import net from "node:net";

const HERDR_ENV = process.env.HERDR_ENV;
const socketPath = process.env.HERDR_SOCKET_PATH;
const socketEndpoint =
  process.platform === "win32" && socketPath ? `\\\\.\\pipe\\${socketPath}` : socketPath;
const paneId = process.env.HERDR_PANE_ID;
const source = "herdr:omp:subagents";
const nestedOmpSession = process.env.OMPCODE === "1";
const MAX_TREE_SLOTS = 8;
let requestQueue = Promise.resolve();

interface SubagentLifecyclePayload {
  id?: string | number;
  status?: string;
  name?: string;
  agent?: string;
  description?: string;
}

interface ToolExecutionEvent {
  toolName?: string;
  args?: {
    tasks?: Array<{
      name?: string;
      agent?: string;
      task?: string;
    }>;
  };
}

interface ExtensionApi {
  events?: {
    on?: (event: string, handler: (payload: unknown) => void) => void;
  };
  on: (event: string, handler: (event: unknown, ctx?: unknown) => void) => void;
}

function sendRequestAttempt(request: unknown, timeoutMs = 800): Promise<boolean> {
  if (HERDR_ENV !== "1" || !socketPath || !paneId || nestedOmpSession) {
    return Promise.resolve(true);
  }

  const { promise, resolve } = Promise.withResolvers<boolean>();
  let done = false;
  let timeout: NodeJS.Timeout | undefined;

  const finish = (delivered: boolean) => {
    if (done) return;
    done = true;
    clearTimeout(timeout);
    socket.destroy();
    resolve(delivered);
  };

  const socket = net.createConnection(socketEndpoint!);
  socket.on("error", () => finish(false));
  socket.on("connect", () => socket.write(`${JSON.stringify(request)}\n`));
  socket.on("data", () => finish(true));
  socket.on("end", () => finish(false));
  timeout = setTimeout(() => finish(false), timeoutMs);
  timeout.unref?.();

  return promise;
}

function sendRequest(request: unknown): Promise<void> {
  requestQueue = requestQueue
    .catch(() => {})
    .then(async () => {
      await sendRequestAttempt(request);
    });
  return requestQueue;
}
export default function (pi: ExtensionApi) {
  if (HERDR_ENV !== "1" || !socketPath || !paneId || nestedOmpSession) {
    return;
  }
  const activeSubagents = new Map<string, string>();
  let lastReportedHash: string | null = null;

  function buildTreeTokens(): Record<string, string | null> {
    const tokens: Record<string, string | null> = {
      subagent: null,
    };

    const names = Array.from(activeSubagents.values());
    const count = names.length;

    if (count === 0) {
      for (let i = 1; i <= MAX_TREE_SLOTS; i++) {
        tokens[`subagent_${i}`] = null;
      }
      return tokens;
    }

    const joined = names.join(", ");
    tokens.subagent = joined.length <= 20 ? `› ${joined}` : `› ${count} subagents`;

    if (count <= MAX_TREE_SLOTS) {
      for (let i = 0; i < count; i++) {
        const isLast = i === count - 1;
        const branch = isLast ? "└─ " : "├─ ";
        tokens[`subagent_${i + 1}`] = `${branch}${names[i]}`;
      }
      for (let i = count + 1; i <= MAX_TREE_SLOTS; i++) {
        tokens[`subagent_${i}`] = null;
      }
    } else {
      for (let i = 0; i < MAX_TREE_SLOTS - 1; i++) {
        tokens[`subagent_${i + 1}`] = `├─ ${names[i]}`;
      }
      const overflow = count - (MAX_TREE_SLOTS - 1);
      tokens[`subagent_${MAX_TREE_SLOTS}`] = `└─ … +${overflow} more`;
    }

    return tokens;
  }

  function reportSubagents() {
    const list = Array.from(activeSubagents.values());
    const tokens = buildTreeTokens();
    const hash = JSON.stringify(tokens);
    if (hash === lastReportedHash) {
      return;
    }
    lastReportedHash = hash;

    const params: Record<string, unknown> = {
      pane_id: paneId,
      source,
      tokens,
    };

    if (list.length > 0) {
      const names = Array.from(activeSubagents.values());
      const joined = names.join(", ");
      const text = joined.length <= 20 ? joined : `${names.length} subagents`;
      params.display_agent = `omp › ${text}`;
    } else {
      params.clear_display_agent = true;
    }

    void sendRequest({
      id: `${source}:${Date.now()}:${Math.random().toString(36).slice(2)}`,
      method: "pane.report_metadata",
      params,
    });
  }

  function clearSubagents() {
    if (activeSubagents.size === 0 && lastReportedHash === null) {
      return;
    }
    activeSubagents.clear();
    reportSubagents();
  }
  // 1. Listen to OMP subagent lifecycle events on event bus
  try {
    pi.events?.on?.("task:subagent:lifecycle", (rawPayload: unknown) => {
      const payload = rawPayload as SubagentLifecyclePayload | undefined;
      if (!payload || !payload.id) return;
      const id = String(payload.id);
      const status = payload.status;
      if (status === "started" || status === "active") {
        for (const [key] of activeSubagents) {
          if (key.startsWith("tool_task_")) {
            activeSubagents.delete(key);
          }
        }
        const label =
          payload.name ||
          payload.agent ||
          (payload.description ? String(payload.description).slice(0, 16) : undefined) ||
          "subagent";
        activeSubagents.set(id, label);
        reportSubagents();
      } else if (
        status === "completed" ||
        status === "failed" ||
        status === "aborted"
      ) {
        activeSubagents.delete(id);
        reportSubagents();
      }
    });
  } catch {}

  // 2. Hook tool execution start/end for task tool
  pi.on("tool_execution_start", (rawEvent: unknown, rawCtx: unknown) => {
    const ctx = rawCtx as { hasUI?: boolean } | undefined;
    if (ctx?.hasUI === false && nestedOmpSession) return;

    const event = rawEvent as ToolExecutionEvent | undefined;
    if (event?.toolName === "task") {
      const tasks = event.args?.tasks;
      if (Array.isArray(tasks) && tasks.length > 0) {
        tasks.forEach((t, idx) => {
          const key = `tool_task_${idx}_${Date.now()}`;
          const name = t?.name || t?.agent || "subagent";
          activeSubagents.set(key, name);
        });
        reportSubagents();
      }
    }
  });

  pi.on("tool_execution_end", (rawEvent: unknown) => {
    const event = rawEvent as ToolExecutionEvent | undefined;
    if (event?.toolName === "task") {
      for (const [key] of activeSubagents) {
        if (key.startsWith("tool_task_")) {
          activeSubagents.delete(key);
        }
      }
      reportSubagents();
    }
  });
  // 3. Clear on agent/session completion, reset, switch, or shutdown
  pi.on("agent_end", () => {
    clearSubagents();
  });

  pi.on("session_switch", () => {
    clearSubagents();
  });

  pi.on("session_shutdown", () => {
    clearSubagents();
  });
}

import net from "node:net";

const HERDR_ENV = process.env.HERDR_ENV;
const socketPath = process.env.HERDR_SOCKET_PATH;
const socketEndpoint =
  process.platform === "win32" && socketPath ? `\\\\.\\pipe\\${socketPath}` : socketPath;
const paneId = process.env.HERDR_PANE_ID;
const source = "herdr:omp:subagents";
const nestedOmpSession = process.env.OMPCODE === "1";

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
  requestQueue = requestQueue.then(
    () => sendRequestAttempt(request),
    () => sendRequestAttempt(request),
  );
  return requestQueue;
}

export default function (pi: ExtensionApi) {
  if (HERDR_ENV !== "1" || !socketPath || !paneId || nestedOmpSession) {
    return;
  }

  const activeSubagents = new Map<string, string>();
  let lastReportedText: string | null = null;

  function formatSubagentText(): string | null {
    if (activeSubagents.size === 0) {
      return null;
    }
    const names = Array.from(activeSubagents.values());
    if (names.length === 1) {
      return names[0];
    }
    const joined = names.join(", ");
    return joined.length <= 20 ? joined : `${names.length} subagents`;
  }

  function reportSubagents() {
    const text = formatSubagentText();
    if (text === lastReportedText) {
      return;
    }
    lastReportedText = text;

    const params: Record<string, unknown> = {
      pane_id: paneId,
      source,
      tokens: {
        subagent: text ? `› ${text}` : null,
      },
    };

    if (text) {
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
    if (activeSubagents.size === 0 && lastReportedText === null) {
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
        const label =
          payload.agent ||
          payload.name ||
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
      for (const key of Array.from(activeSubagents.keys())) {
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

---
description: Serve change docs to a phone browser.
---
## Load

- Read project `.omp/RULES.md` if present; otherwise read `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/RULES.md`. Stop if neither exists.
- This is a read-only viewing aid. It creates no change artifacts, runs no gate and records no approval.

## Start, stop or inspect

- Locate the installed viewer from the physical commands directory:
  - `CONFIG="${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}"`
  - `COMMANDS_DIR="$(cd "$CONFIG/commands" && pwd -P)"`
  - `VIEWER="$(dirname "$COMMANDS_DIR")/view-docs.sh"`
  - If the viewer is missing or not executable, stop and report the path.
- Arguments: `$1` optional change slug or `stop`/`status`; `$2` optional bind host (default `0.0.0.0`); `$3` optional port (default `8765`). Set `HOST="${2:-0.0.0.0}"` and `PORT="${3:-8765}"`.
- For `stop` or `status`, run `"$VIEWER" "$1" "" "$HOST" "$PORT"` and report the result.
- Otherwise require `openspec/changes` in the current project. If `$1` is set, serve only `openspec/changes/$1` after confirming it exists; if it does not, list the available changes and stop. With no slug, serve all changes.
- Run `"$VIEWER" start "$ROOT" "$HOST" "$PORT"` in the background via the wrapper. Never bind publicly or expose the port through a tunnel without explicit authorization.
- Report the actual `Local:` and `Phone:` URLs from the output, the fact that the page is read-only, and how to stop it: `/work-view stop`.
- Run agent-facing shell checks through `rtk` per shared rules. The wrapper's internal control flow (PID checks, `nohup`, `kill`, `curl` readiness) is native plumbing and is exempt; keep its failures visible.
- Mermaid fences render in the browser through the pinned jsDelivr module. If the CDN is unreachable, the source code block remains visible; report that fallback rather than claiming a rendered diagram.
- If the viewer fails, show the log path and the actual failure. Do not retry with another port without telling the human.

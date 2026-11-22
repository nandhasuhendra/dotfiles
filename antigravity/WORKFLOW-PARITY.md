# OMP → Antigravity CLI parity

| OMP capability | Port status | Notes |
| --- | --- | --- |
| Slash commands | Ported as skills | Skills become `/<name>` in the CLI TUI. |
| Custom agents | Ported | Antigravity frontmatter uses `model: flash|pro|inherit`; OMP provider aliases are not portable. |
| Shared rules | Ported | One explicit opt-in `AGENTS.md`; avoids activating the workflow on every coding request. |
| Context7 MCP | Ported | Remote Streamable HTTP endpoint. |
| Playwright MCP | Ported | Local stdio via npx; first use may download browser assets. |
| Gate 1 / Gate 2 | Behavioral approximation | Conversational stop-and-wait, not OMP's native ask primitive. |
| Native task batching | Partial | Use `invoke_subagent`; verify independent sessions and parallel execution from actual transcript. |
| Diff fingerprinting | Ported procedurally | Shell `sha256sum`/Git commands; reports store the fingerprint. |
| Stale evidence invalidation | Ported procedurally | Recompute before ship; changed fingerprint blocks. |
| Read-only reviewers | Prompt-enforced | Do not claim OS/tool-level write protection unless permissions actually enforce it. |
| Security audit validators | Bundled standalone | Complete Cloudflare skill, companion docs, schema, validators, tests, and MIT license live under `antigravity/skills/security-audit`; no OMP/OpenCode checkout required. |
| 60K compaction threshold | Not portable | Antigravity controls compaction internally; preserve durable workflow state in files. |
| Model role routing/fallback | Not portable | Antigravity model tiers are not equivalent to OMP provider/model selectors or retry chains. |
| OMP extensions (RTK/Herdr) | Not ported | Tooling-specific extension APIs are not compatible. |

## Acceptance checklist

- [ ] `agy skills` lists every `work-*`, `review-*`, and `security-audit` skill.
- [ ] `agy agents` lists all intended custom agents.
- [ ] `agy mcp list` shows Context7 and Playwright connected.
- [ ] `/work-spec` asks for Gate 1 and waits; it does not create artifacts before approval.
- [ ] Gate 2 is unavailable until both independent design reviews PASS on the current fingerprint.
- [ ] `/work-build` refuses implementation without current-conversation Gate 2 approval.
- [ ] Review-only commands do not change application files.
- [ ] Review evidence becomes stale after any target diff change.
- [ ] `/work-ship` refuses stale/missing/failed required quality evidence.
- [ ] No real security-audit target execution occurs without an OS-enforced sandbox.
- [ ] Cost, elapsed time, retries, and model usage are recorded for the same benchmark tasks used with OMP.

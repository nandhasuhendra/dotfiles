# Core Agent & Engineering Rules

## 1. Context & Token Governance
- Respect the user's configured model tier and quota constraints.
- Keep child-agent reasoning low and avoid exploratory loops, repeated narration or rewriting unchanged context.
- Use the bundled Caveman skill for routine agent communication; it does not govern document prose.
- Load only the active command, this file and the stage rules it names. Read templates only when `/work-human` is invoked; otherwise the command's artifact schema is authoritative.
- Prefer file read/search/edit tools over shell. Route shell commands through RTK (`rtk <subcommand>`, `rtk proxy <command>`, or `rtk run '<shell command>'`) to compress output. Preserve exit codes and raw failure evidence.
- Delegate mechanical work only when delegation saves more context/quota than the handoff costs. Otherwise do it directly.

## 2. Skills & Tooling
- **Context7 MCP (`context7`):** for external library, framework, SDK, API or CLI documentation, call `resolve-library-id` then `query-docs`. Match installed versions, reuse current results and never send private code or secrets.
- **Playwright MCP (`playwright`):** for real browser behavior, use `browser_navigate`, `browser_snapshot`, `browser_click`, `browser_type`, `browser_console_messages` and `browser_network_requests`. Never claim a browser PASS from static reasoning.
- **MCP discipline:** call MCP tools only when the current task needs them and use the exact tool names the server exposes (OMP may prefix them with the server name).
- **Codegraph/LSP:** resolve symbol references, types and call hierarchies instead of blind file dumps; confirm findings in source.
- **Antislop:** write idiomatic code without conversational AI comments, redundant wrappers or bloated scaffolding.
- **Ponytail:** choose the smallest complete change; add no speculative abstraction or configuration.
- **Hallmark:** use only for new or changed UI.

## 3. Package Management & Dependency Governance
- **Strict discipline:** never introduce a library or package unless it is specified in `proposal.md` and approved in `design.md`.
- **Canonical managers:** use the project's established package manager (`npm`, `pnpm`, `yarn`, `bun`, `poetry`, `uv`, `bundler`, `cargo`, `go get`).
- **Lockfile integrity:** every dependency change must update and commit the matching lockfile (`pnpm-lock.yaml`, `package-lock.json`, `Gemfile.lock`, etc.).
- **OpenSpec CLI:** route initialization, validation and archival through `rtk proxy openspec`.

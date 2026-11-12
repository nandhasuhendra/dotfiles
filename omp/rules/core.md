# Core Agent & Engineering Rules

## 1. LLM & Context Governance
- Agents must strictly respect the user's configured model tier and quota constraints.
- Restrict excessive thinking/reasoning loops on child subagents to eliminate token burn.
- Mechanical tasks (Git operations, status queries, text formatting) must be delegated to lightweight/free tiers (`sonic` / `@execution_tier`).

## 2. Skills & Tooling Integrations
- **Codegraph:** Leverage Codegraph and LSP AST operations to resolve symbol references, type definitions, and call hierarchies rather than performing blind file dumps.
- **Antislop & Clean Code:** Produce idiomatic, clean code free of conversational AI comments, redundant wrappers, or bloated scaffolding, adhering strictly to existing repository patterns.
- **Ponytail & Hallmark:** Respect active project formatting rules, linters, and quality standards.

## 3. Package Management & Dependency Governance
- **Strict Dependency Discipline:** Never introduce new libraries or packages unless explicitly specified in `proposal.md` and approved in `design.md`.
- **Canonical Package Managers:** Use the project's established package manager (`npm`, `pnpm`, `yarn`, `bun`, `poetry`, `uv`, `bundler`, `cargo`, `go get`).
- **Lockfile Integrity:** Every dependency addition must ensure lockfiles (`pnpm-lock.yaml`, `package-lock.json`, `Gemfile.lock`, etc.) are consistently updated and committed.
- **OpenSpec CLI Integration:** Route OpenSpec initialization and archival through `rtk proxy openspec`.

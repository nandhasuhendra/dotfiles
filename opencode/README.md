# OpenCode engineering workflow

Port of the [OMP workflow](../omp/README.md) to OpenCode's builtin features: same six commands, same two-gate pipeline, same read-only review/QA agents — with fewer always-loaded tokens.

## What replaces what

| OMP mechanism | OpenCode builtin | Effect |
| --- | --- | --- |
| `RULES.md` + 6 `rules/*.md` files | One small `AGENTS.md` (always in context) + stage rules merged into each command file | one file read per command instead of 3–6 |
| `task.agentModelOverrides` + `modelRoles` + `fallbackChains` | per-agent `model:` frontmatter | no routing docs; routing is 5 lines |
| `ask` tool | builtin `question` tool | same blocking gates |
| `mcp.json` | `mcp` block in `opencode.jsonc` | same two servers |
| bundled skills dir | `skills/` — OpenCode loads only skill frontmatter until relevant | description-only token cost |
| OMP `task` tool | builtin `task` subagent tool (`mode: subagent` agents) | same delegation |

Model tiers (verify against `opencode models`; the omp `opencode-zen/...` prefixes are this harness's `opencode/...`):

| Agent | Model |
| --- | --- |
| tech-lead | `openai/gpt-5.6-sol:medium` |
| summary-reviewer | `zai/glm-5.3#high` |
| software-engineer, qa-engineer | `opencode/deepseek-v4.1-flash-free` |
| code-reviewer, pattern-reviewer, performance-engineer, security-engineer, principal-engineer (review) | `zai/glm-5.3-flash#low` |

OpenCode has no native model-fallback chain; rerun or switch the agent's `model:` on provider failure.

## Token-efficiency choices

- Each command is self-contained: read only the invoked command plus change artifacts. Never scan agents, skills or templates.
- `AGENTS.md` is the only always-in-context workflow file and is kept deliberately small.
- Skills (caveman, hallmark, security-audit) are symlinked from `omp/skills/` and cost only their description until invoked.
- Agents are lean prompts; review/QA/security agents have `write`/`edit` tools disabled in frontmatter, so blast-radius limits are tool-level, not just prompt-level.
- OMP-only installers are dropped: no forced RTK/Codegraph installs and no installer-run npm installs. Both are used opportunistically when present — RTK for shell/CLI compression, Codegraph for source-confirmed impact (`codegraph context/impact/affected`). OpenSpec CLI is still required for the artifact lifecycle — commands use `rtk openspec` when `rtk` exists, else plain `openspec`. `rtk` installs a global hook/plugin so matching commands are rewritten automatically; filtered CLIs and `rtk recall <hash>` recover elided output.

## Commands

`/work-spec`, `/work-human`, `/work-build`, `/work-resume`, `/work-status`, `/work-ship` — semantics identical to the OMP versions (interview → Gate 1 → artifacts → validate → independent security + principal-engineer design review → Gate 2 → build → quality choice → ship). Quality reports live in `openspec/changes/<slug>/quality/` (slug targets) or `.reviews/quality/<branch>/` (branch targets) and include `review.md`, `qa.md` and, when the risk trigger fires, `security.md`. Spec-stage design reviews live in `openspec/changes/<slug>/review/security.md` and `review/engineering.md`.

`/security-audit [target] [quick|standard|deep] [output-dir]` — standalone, non-gated audit of the [Cloudflare security-audit skill](https://github.com/cloudflare/security-audit-skill). This session is the parent: it owns `run-metadata.json`, `architecture.md`, `coverage-ledger.json`, `findings.json`, `REPORT.md`, `FINDINGS-DETAIL.md` and `NEEDS-VALIDATION.md`, runs both validators and dispatches three read-only subagents:

| Agent | Responsibility |
| --- | --- |
| `security-audit-recon` | Reconnaissance 1a–1d and post-wave coverage critics. |
| `security-audit-hunter` | Coverage-led hunting; exactly one structured JSON result per assignment. |
| `security-audit-verifier` | Adversarial candidate validation (Phase 3) and final record verification (Phase 5). |

Full audit mode requires an explicit audit/pen-test/full-review request; security questions stay in guidance mode. Output defaults to `~/security-audit-skill/<repo>/run-<N>` and is written inside the target only when the user selects an ignored directory. Target-controlled execution needs the OS-enforced sandbox from `SKILL.md`; otherwise decisive leads stay `needs_validation`. The vendored skill is `skills/security-audit` (symlinked from `omp/skills/security-audit`); see its `UPSTREAM.md`. Remove any project-local `.agents/skills/security-audit` so the bundled copy remains the single source.

The workflow calls it automatically: `/work-build … review-and-qa` evaluates a deterministic risk trigger on the target diff and, when it fires, records `security.md` with `status: deferred` next to `review.md`/`qa.md` (trigger reasons, fingerprint, pointer to `/security-audit`) — no extra subagents are dispatched, the hard cap is 2. With no trigger it records `status: not_triggered`. Review/QA/security results are advisory evidence summarized into the change docs and human docs; they never gate `/work-ship`, and `/work-status` / `/work-resume` report missing or stale review evidence as advisory context.

`/review-docs [active|archive|specs|openspec|<slug>|<path-or-glob>] [output-dir]` applies the security + `principal-engineer` design-review contract to documents that already exist — active and archived OpenSpec changes, `openspec/specs/**/spec.md` baseline capabilities, ADRs, RFCs, threat models and runbooks. It fingerprints each unit, writes `<output-dir>/security/<unit>.md`, `<output-dir>/engineering/<unit>.md` and a consolidated `SUMMARY.md` (default `.reviews/<timestamp>-docs/`), stays read-only, and its findings are advisory input for Gate 2.

`/review-security`, `/review-patterns`, `/review-performance` and `/review-all` are read-only code reviews over a branch diff, path, glob or OpenSpec slug. Instead of spawning subagents in parallel, each command creates a review plan (`PLAN.md`) first, executes review steps sequentially using cheaper Z.ai GLM Flash (`zai/glm-5.3-flash#low`), and reviews/synthesizes summary files using higher Z.ai GLM (`zai/glm-5.3#high`):

| Command | Review Step(s) | Focus |
| --- | --- | --- |
| `/review-security` | `security-engineer` | static exploitability: injection/RCE, XSS, authz/tenant scope, secrets, SSRF, uploads, rate limits |
| `/review-patterns` | `pattern-reviewer` | SOLID/KISS/YAGNI, boundaries, coupling, duplication, dead code, change risk |
| `/review-performance` | `performance-engineer` | N+1, indexes, scans, pagination, complexity, memory, I/O, caching, concurrency |
| `/review-all` | `code-reviewer` + 3 above (docs: security + principal) | correctness, security, patterns and performance with one deduplicated `SUMMARY.md` |

They default to `.reviews/<timestamp>-<dimension>/`, never edit the reviewed code, and surface confirmed P0/P1 prominently as advisory findings — shipping requires only explicit user review confirmation. Use `/security-audit` when a finding needs a coverage-led, independently verified audit.

## Install

From the dotfiles repository root:

```bash
bash opencode/install-opencode.sh
```

Links `AGENTS.md`, `agents/`, `commands/`, `skills/`, `templates/` and `opencode.jsonc` into `~/.config/opencode/` with timestamped backups of any existing files. Requires OpenCode ≥ 2.x and a working `openspec` CLI on PATH for the OpenSpec stages.

Start a new OpenCode session after installation. Explicit opt-in semantics match OMP: nothing activates without an explicit `/work-*` command.

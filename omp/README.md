# OMP engineering workflow

Custom agents and slash commands for requirements, approval, QA and implementation. Shared policy: [RULES.md](RULES.md).

## Context and token efficiency

The workflow is evidence-first without requiring every agent to load every artifact. Agents enumerate and hash all gate-bound inputs, read the complete authoritative inputs required for their decision, and retrieve supporting material only when relevant. Handoffs pass artifact paths, manifest identities, stable REQ/TC IDs, concise findings and unresolved questions instead of copying whole documents. Independent reviewers still inspect the authoritative inputs, relevant source/diff and actual evidence; context reduction never relaxes approval, freshness, coverage or verification gates.

## Install

From the dotfiles repository root:

```bash
bash omp/install-omp.sh
```

Requires Linux or macOS, Node.js **20.19+**, npm, OMP, Git, curl and tar already on PATH. The installer installs missing workflow dependencies, verifies them, then replaces configuration. It never invokes `sudo` or edits your shell profile.

Configuration goes into `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`. Existing `mcp.json`, `agents/`, `commands/`, `RULES.md` and `templates/` are moved to timestamped backups and replaced with current source links. Matching links remain unchanged. All four document templates are required and checked before dependency installation. Optional `skills/` and `extensions/` are linked only if present.

CLI packages go into `${NPM_CONFIG_PREFIX:-$HOME/.local}`; keep its `bin/` directory first on PATH when starting OMP. The installer prints the exact shell command. Chromium uses Playwright's managed browser cache; Ponytail uses OMP's user plugin store.

The terminal UI shows five real stages with text labels and terminal-palette colors: cyan for stages/running work, green for ready/success, yellow for backups/notices and red for errors. Color is supplementary, not the only status signal. Redirected output, `TERM=dumb` and `NO_COLOR` produce plain text. Full command logs are retained under `<config-dir>/install-logs/`; a failed dependency check stops before configuration replacement.

Start a new OMP session after installation. Commands explicitly load project `.omp/RULES.md` or the installed global rules. A project override must preserve the gates.

## Dependencies

| Tool | Delivery | Workflow role |
| --- | --- | --- |
| OpenSpec | Reuse a working CLI, otherwise install `@fission-ai/openspec@1.14.3` | Change lifecycle, schema artifacts, validation and archive. |
| Ponytail | Verify installed skill, otherwise register `DietrichGebert/ponytail` and install its OMP plugin | Smallest complete implementation; no unnecessary abstraction. |
| Codegraph | Reuse a working CLI, otherwise install `@colbymchenry/codegraph@1.6.2` | Source-confirmed impact, callers and regression scope. |
| Playwright | Install/verify `@playwright/mcp@0.0.83`, install its matching Chromium and render a smoke page | Real browser acceptance and regression checks. |
| Context7 | Configure hosted MCP and verify a real MCP initialize response; no local package needed | Current library/API/CLI documentation, matched to installed versions. |
| rtk-ai | Reuse a verified `rtk`, otherwise run the official v0.45.0 installer with release checksum verification enforced | Wrap every model-facing shell command; specialized subcommands, proxy or run. |

Only Playwright and Context7 need the MCP entries supplied here. Installed tools are verified by actual invocation, not PATH lookup alone. Working CLIs and Ponytail are not automatically upgraded on repeat runs; Playwright is kept at the configured version.

Check actual invocations before starting:

```bash
openspec --help
codegraph --help
rtk --help
```

Read the installed Ponytail skill and confirm the two MCP tool sets are available in OMP. OpenSpec and Ponytail must work before their required stages; unavailable browser automation blocks browser verification. Other fallbacks and evidence requirements are defined in RULES.md.

### Shell commands

Every model-facing shell command goes through `rtk`:

| Route | Use |
| --- | --- |
| `rtk <subcommand>` | Preferred for supported tools: `rtk git status`, `rtk grep`, `rtk test`, `rtk playwright`. |
| `rtk proxy <command> [args]` | Specialized route rejects required flags, hides needed failure detail, or the command is unsupported. |
| `rtk run '<shell command>'` | Pipelines, redirection or compound shell syntax. |

File read/search/edit tools remain preferred over shell. Internal script plumbing that produces no agent-facing output may run natively. Preserve exit status and raw failure output; RTK compression is not verification. If `rtk` is unavailable, run the original command and record the fallback. `rtk gain -p` reports adoption or savings, not correctness.

### Use by stage

| Stage | Required tools | Evidence |
| --- | --- | --- |
| Interview | OpenSpec, rtk | CLI versions/help, wrapped commands |
| Spec | OpenSpec, Codegraph, Context7, Ponytail, rtk | schema, impact, library/version, smallest solution |
| QA | OpenSpec, Codegraph, Playwright when browser, rtk | regression surface, planned flows, commands |
| Implement | Ponytail, Codegraph, Context7, rtk | smallest change, confirmed callers, version docs, raw commands |
| Verify | OpenSpec, Playwright when browser, rtk | validation, observed browser evidence, raw logs |
| Security | Codegraph, Context7, Playwright when applicable, rtk | abuse paths, version behavior, browser evidence |

Record each actual invocation in the handoff `Evidence` line, or mark it N/A with a reason. Naming a tool without running it is not use.

Installation boundaries:

- Node/npm/OMP and platform tools are prerequisites, not bootstrapped. No nodenv/global Node version changes.
- Installation requires npm/GitHub downloads and Context7 connectivity. Package managers and the official RTK installer execute upstream code; RTK's downloaded release archive is checksum-verified. No repository indexing or project `openspec init` runs automatically.
- Chromium no longer uses a machine-specific executable path. The existing `--no-sandbox` policy remains explicit in config and installer output: use trusted test content or an isolated environment.
- Linux may need Chromium OS libraries. Browser launch errors remain in the full log; install the reported platform libraries and rerun rather than treating a browser download as a successful launch.

## Document templates

| Template | Output / author | Command |
| --- | --- | --- |
| [PRD](templates/PRD.md) | `prd.md` / product-manager | `/work-spec <slug>` on product/mixed work |
| [Tech Doc](templates/TECH-DOC.md) | `design.md` / tech-lead | `/work-spec <slug>` when design is required |
| [QA Test Case Scenarios](templates/QA-TEST-CASES.md) | `test-plan.md` / qa-engineer | `/work-qa <slug>` after spec approval |
| [Task Breakdown](templates/TASK-BREAKDOWN.md) | `tasks.md` / tech-lead | `/work-plan <slug>` after QA-plan approval |

Adapted from the supplied EVA document templates and embedded QA scenarios, retaining structure rather than EVA-specific repositories, frameworks, tenant policies or CRUD ordering. They use short sections, observable acceptance criteria and stable REQ/TC/SEC/task links.

Authors read project `.omp/templates/<filename>` first, then the installed `templates/` directory as fallback. Missing templates block authoring. Re-run the installer to expose the supplied templates; do not overwrite approved artifacts by copying blank templates into a change.

OpenSpec's installed schema controls required headings and checkbox syntax for its artifacts; these templates supply the content checklist. Replace example rows/tokens, retain explicit unknowns as blockers, and link real evidence only. QA plans remain specifications: execution results go into `verification.md`.

## Read on your phone

Use the command from the project:

```text
/work-view
/work-view <change-slug>
/work-view stop
```

Or run the wrapper directly:

```bash
omp/view-docs.sh start /path/to/project/openspec/changes 0.0.0.0 8765
```

Open the printed `http://<laptop-lan-ip>:8765/` on a phone connected to the same Wi-Fi. The index lists each change; Markdown tables, relative `.md` links and Mermaid fences render. The command runs the viewer in the background and `/work-view stop` stops it.

- Mermaid uses a pinned jsDelivr module in the browser. If the CDN is unreachable, the diagram stays as a readable code block; no diagram is claimed.
- No authentication. Use a trusted network. For access away from home, bind to the Tailscale IP (`tailscale ip -4`) or use a private tunnel; never expose the port publicly.
- For offline or anywhere reading without the laptop, sync `openspec/changes/` with Syncthing or add it to an Obsidian vault.
- `openspec view` is a terminal dashboard, not a phone-accessible page.

## Roles

| Agent | Responsibility |
| --- | --- |
| interviewer | Ask 1–3 plain-language questions per round; keep interviewing until readiness passes, then request explicit approval. |
| product-manager | Convert product requirements into a business-facing PRD with measurable REQ IDs. |
| tech-lead | Write engineering design and OpenSpec-compatible implementation tasks. |
| qa-engineer | Write traceable TC scenarios after spec approval; independently verify implementation later. |
| security-engineer | Red-team attack-path analysis and blue-team defenses, mitigations and security regression checks. |
| reviewer | Independently review gate inputs and final changes, with concrete evidence. |
| software-engineer | Implement only the approved, reviewed and testable scope. |

Product work requires `prd.md`; engineering work requires `design.md`; mixed work requires both. OpenSpec schema-required artifacts still apply. Extra technical design is required when a product change needs technical decisions.

### Agent flow

| Stage | Author | Independent check | Handoff |
| --- | --- | --- | --- |
| Interview | interviewer | reviewer | `interview.md` + checkpoint |
| Specify | product-manager, tech-lead | security-engineer, reviewer | `prd.md`/`design.md` + OpenSpec bundle + checkpoint |
| QA | qa-engineer | reviewer | `test-plan.md` + checkpoint |
| Plan | tech-lead | reviewer + OpenSpec validation | `tasks.md` + checkpoint |
| Implement | software-engineer | none midflight | source/tests + task evidence |
| Verify | qa-engineer, security-engineer | reviewer | `verification.md` + archive checkpoint |
| Archive | orchestrator | OpenSpec validation | archived change |

Every author returns the shared handoff block from `RULES.md`. The orchestrator runs the review, presents one checkpoint and records the human reply; no author records approval.

## Command sequence

Replace `change-slug` with the slug recorded by the interview. Each stage command authors the work, runs its independent review, then presents one checkpoint. Reply once; you do not need a separate review command.

| Step | Command | Result / checkpoint |
| --- | --- | --- |
| Interview | `/work-new <request>` | Ask adaptive questions until requirements fit; write `interview.md`, review, then ask for approval. |
| Specify | `/work-spec change-slug` | PRD/design plus OpenSpec proposal and delta specs; security and reviewer PASS, then approval. |
| QA plan | `/work-qa change-slug` | Positive, negative, boundary and regression scenarios; review, then approval. |
| Plan | `/work-plan change-slug` | Tasks linked to REQ/TC IDs, OpenSpec validation and review, then approval. |
| Implement | `/work-implement change-slug` | Implement approved tasks; preserve scope and send to independent verification. |
| Verify | `/work-verify change-slug` | Independent QA/security/reviewer checks and evidence; archive authorization checkpoint. |
| Archive | `/work-archive change-slug` | Revalidate, archive only after explicit authorization. |
| Review | `/work-review change-slug` | Review a pending gate or verification target. |
| Approve | `/work-approve change-slug approve` | Record an explicitly supplied decision against the current manifest. |
| Resume | `/work-resume change-slug` | Recheck manifests and resume at the first valid pending stage. |
| View | `/work-view [change-slug]` | Read workflow artifacts in a mobile-friendly local browser. |

See [RULES.md](RULES.md) for approval freshness, evidence, tool fallbacks and safety constraints.

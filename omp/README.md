# OMP engineering workflow

Custom agents and slash commands for human-first product/technical planning, OpenSpec preparation, QA and implementation. Shared policy: [RULES.md](RULES.md).

## Context and token efficiency

The workflow is evidence-first without requiring every agent to load every artifact. Agents enumerate and hash all gate-bound inputs, read the complete authoritative inputs required for their decision, and retrieve supporting material only when relevant. Handoffs pass artifact paths, manifest identities, stable REQ/TC IDs, concise findings and unresolved questions instead of copying whole documents. Independent reviewers still inspect the authoritative inputs, relevant source/diff and actual evidence; context reduction never relaxes approval, freshness, coverage or verification gates.

## Install

From the dotfiles repository root:

```bash
bash omp/install-omp.sh
```

Requires Linux or macOS, Node.js **20.19+**, npm, OMP, Git, curl and tar already on PATH. The installer installs missing workflow dependencies, verifies them, then replaces configuration. It never invokes `sudo` or edits your shell profile.

Configuration goes into `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`. Existing `mcp.json`, `agents/`, `commands/`, `RULES.md` and `templates/` are moved to timestamped backups and replaced with current source links. Matching links remain unchanged. All five document templates are required and checked before dependency installation. Optional `skills/` and `extensions/` are linked only if present.

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

## Human-first command sequence

| Step | Command | Output and gate |
| --- | --- | --- |
| 1. Interview | `/work-new <request>` | Gather requirements and approve the interview. No OpenSpec specs yet. |
| 2. Product planning | `/work-product-plan <slug>` | Draft human-readable `prd.md` when applicable; final review happens with the Tech Doc. |
| 3. Technical planning | `/work-tech-plan <slug>` | Human-readable `design.md` and `task-breakdown.md`. |
| 4. Human document review | `/work-doc-review <slug>` | Independent review and approval of the complete human planning bundle. |
| 5. Implementation preparation | `/work-prepare <slug>` | Translate approved docs into OpenSpec artifacts, validate REQ traceability, review and approve. |
| 6. QA planning | `/work-qa <slug>` | Agent-ready scenarios derived from approved requirements; review and approval. |
| 7. Agent task planning | `/work-plan <slug>` | OpenSpec-compatible `tasks.md` linked to REQ/TC IDs; review and approval. |
| 8. Build and verify | `/work-implement <slug>` then verification | Implement approved tasks; verify real evidence, regressions and security. |
| 9. Complete | `/work-archive <slug>` | Requires final verification and explicit archive authorization; merge/release remains separate. |

**Important:** `task-breakdown.md` is for people; `tasks.md` is the agent-ready execution checklist. Human planning docs are the source of truth. If OpenSpec preparation discovers an unresolved material decision or changes approved intent, return to planning and re-review.

## Document templates

| Template | Output / author | Command |
| --- | --- | --- |
| [PRD](templates/PRD.md) | `prd.md` / product-manager | `/work-product-plan <slug>` |
| [Tech Doc](templates/TECH-DOC.md) | `design.md` / tech-lead | `/work-tech-plan <slug>` |
| [QA Test Case Scenarios](templates/QA-TEST-CASES.md) | `test-plan.md` / qa-engineer | `/work-qa <slug>` after spec approval |
| [Human Task Breakdown](templates/HUMAN-TASK-BREAKDOWN.md) | `task-breakdown.md` / tech-lead | `/work-tech-plan <slug>` |
| [Agent Task Checklist](templates/TASK-BREAKDOWN.md) | `tasks.md` / tech-lead | `/work-plan <slug>` after QA-plan approval |
| [Agent Task Checklist](templates/TASK-BREAKDOWN.md) | `tasks.md` / tech-lead | `/work-plan <slug>` after QA-plan approval |

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
| tech-lead | Write the human Tech Doc and task breakdown, then derive agent-ready OpenSpec tasks after QA planning. |
| qa-engineer | Write traceable TC scenarios after spec approval; independently verify implementation later. |
| security-engineer | Red-team attack-path analysis and blue-team defenses, mitigations and security regression checks. |
| reviewer | Independently review gate inputs and final changes, with concrete evidence. |
| software-engineer | Implement only the approved, reviewed and testable scope. |

Product work requires `prd.md`; engineering work requires `design.md`; mixed work requires both. OpenSpec schema-required artifacts still apply. Extra technical design is required when a product change needs technical decisions.

### Agent flow

| Stage | Author | Independent check | Handoff |
| --- | --- | --- | --- |
| Interview | interviewer | reviewer | `interview.md` + checkpoint |
| Product planning | product-manager | independent reviewer | human `prd.md` + checkpoint |
| Technical planning | tech-lead | independent review in next gate | human `design.md` + `task-breakdown.md` |
| Human document review | reviewer | orchestrator checkpoint | approved human source-of-truth bundle |
| Implementation preparation | product-manager, tech-lead | security-engineer, reviewer | OpenSpec proposal/spec bundle + REQ mapping + checkpoint |
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
| Product planning | `/work-product-plan change-slug` | Draft human PRD; final approval is in the combined review. |
| Technical planning | `/work-tech-plan change-slug` | Human Tech Doc and task breakdown. |
| Human doc review | `/work-doc-review change-slug` | Independent review and approval of human docs. |
| Implementation prep | `/work-prepare change-slug` | Translate approved docs to OpenSpec specs; validate and review. |
| QA plan | `/work-qa change-slug` | Positive, negative, boundary and regression scenarios; review, then approval. |
| Plan | `/work-plan change-slug` | Tasks linked to REQ/TC IDs, OpenSpec validation and review, then approval. |
| Implement | `/work-implement change-slug` | Implement approved tasks, then run independent verification automatically. |
| Verify | `/work-verify change-slug` | QA, security-engineer and reviewer evidence per scenario; present archive authorization. |
| Close | `/work-archive change-slug` | Requires verification PASS and explicit archive authorization. Does not authorize merge/deploy. |

Every checkpoint offers the same replies:

| Reply | Effect |
| --- | --- |
| `approve` | Record the decision, then continue to the next stage. |
| `approve stop` | Record and stop; resume later with `/work-resume change-slug`. |
| `reject: <reason>` | Record rejection without approval and send the work back to its author. |
| `revisit: <question/stage>` | Reopen that stage; changed inputs invalidate dependent records. |
| `pause` | Write nothing; resume with `/work-resume change-slug`. |

`/work-review change-slug <target>` is optional for a re-review or a standalone checkpoint. `/work-approve change-slug <target> [decision]` resumes a pending decision. `/work-status change-slug` shows one next action. Neither invocation nor silence counts as approval.

## What makes a gate valid

- `review.md` records independent PASS against actual input paths and SHA-256 digests.
- `approvals.md` records the human decision and matching manifest. The agent recomputes it after confirmation and before every dependent transition.
- Changed, added or deleted inputs invalidate their approval and dependent evidence. Old records remain history, not permission.
- Approved `tasks.md` stays frozen during implementation. Execution progress goes in `verification.md`; OpenSpec checkbox completion is reconciled at authorized archive.
- Verification identifies the actual source, including dirty/untracked changes, and records real commands, exit codes and browser observations.
- No separate agent for required independent review/QA means BLOCKED, not self-certified PASS.
- Security review uses two perspectives within one independent security-engineer run, not two approvals. Spec review assesses proposed defenses; final verification checks implemented defenses against real evidence. Missing security dispatch/evidence or unresolved findings blocks the gate.

These gates are prompt-level policy, not executable access control. This configuration does not ship a gate script or write-blocking hook. OpenSpec validation checks schema/spec structure, not human approval or software correctness.

## Readable artifacts

All change artifacts live under `openspec/changes/<slug>/`. Use short sections, bullets, compact tables and paragraphs of at most three sentences. Keep confirmed facts separate from assumptions and blockers.

A test scenario should fit in one row:

| TC | REQ | Given | When | Then | Layer |
| --- | --- | --- | --- | --- | --- |
| TC-001 | REQ-001 | An existing authorized user | They submit valid input | The specified change persists and appears after reload | Integration/browser |

This row illustrates the format, not a requirement for your application. Real scenarios must come from approved requirements and repository behavior.

## Configuration changes

- Replaced references to a nonexistent gate script with one explicit review/approval/freshness protocol.
- Aligned all seven agents and twelve commands with the gated lifecycle and six dependency roles, including red-team/blue-team security review.
- Fixed installation of workflow rules and handling of absent optional directories.
- Replaced stale agent, template and MCP documentation with the current configuration.
- Added dependency installation/verification and a staged, theme-native terminal UI with plain-text fallback and retained failure logs.
- Added four reusable document templates, required installation and gated author/command integration; added semantic installer colors without changing plain-text behavior.

## Verification

- Clean-home Linux smoke installed OpenSpec, Codegraph, checksum-verified RTK, Ponytail and Playwright; Chromium rendered/read a page and Context7 completed a real MCP handshake.
- Existing-install smoke reused working tools, installed missing tools, preserved existing rules in a backup and exposed all seven agents.
- Earlier isolated regression checks covered backup collisions/idempotence, dependency-failure preservation and broken-shim replacement.
- Terminal UI observed in a real 44-column PTY; redirected `NO_COLOR` and `TERM=dumb` output had no ANSI escapes. UI-only checks isolated external dependency commands; the separate installation smoke used real downloads and services.
- Current template/color smoke installed all four templates, preserved an old template directory in backup and repeated without extra backups. Cyan/green/yellow statuses appeared in a 48-column PTY; missing-template failure showed red and stopped before dependency installation/config replacement. `NO_COLOR` and `TERM=dumb` stayed plain.
- Template drafting smoke used actual OMP to instantiate four fictional draft documents: all three fixture requirements traced through design/QA/tasks, cases remained NOT_RUN, task checkboxes remained unchecked and no template tokens remained. No approvals or active workflow transitions were fabricated; disposable drafts were removed afterward.
- All seven agent and twelve command frontmatter documents parsed. Actual OMP dispatch found `security-engineer`, which returned BLOCKED for missing spec/manifest inputs without probing systems or writing records.
- Checkpoint smoke on a disposable OpenSpec workspace: `/work-review demo interview` dispatched an independent reviewer, which recorded INT-001 PASS with a matching SHA-256 manifest. Re-running the command reused that PASS and presented one menu (`approve`, `approve stop`, `reject`, `revisit`, `pause`) without recording approval. `/work-status` recommended the same single action; `/work-approve demo interview pause` wrote no approval.
- Phone viewer smoke served a disposable `openspec/changes` fixture: index listing, rendered Markdown table, relative `.md` link, and rejection of traversal/non-Markdown paths passed.
- Real Chromium rendered a Mermaid flowchart to `.mermaid svg` with zero console errors; the nonce policy allowed only the pinned jsDelivr module plus the inline renderer.
- `/work-view demo` started a single-change viewer, returned HTTP 200, and `/work-view stop` stopped it. Wrapper `start`/`status`/`stop` also passed with state cleanup.
- RTK smoke: `rtk proxy` preserved exit code 7, `rtk run` executed a pipeline and returned 2, and `rtk git`/`rtk grep` produced usable output. OMP selected the specialized `rtk git status --short --branch` route; an earlier smoke deliberately used `rtk proxy` for full output.
- Tool-use rules and evidence requirements were updated in RULES, all agents and stage commands. They remain prompt-level instructions, not runtime enforcement.
- The approve/reject/revisit transitions and full approval-to-archive happy path were not exercised, so approval recording and downstream continuation are not proven end-to-end. Application-specific security/browser scenarios and macOS installation were not run. Refusal and checkpoint smokes do not guarantee enforcement.
- Checkpoint smoke fixture was disposable and uncommitted; its interview, review and workspace were removed from the repository context.

Installation references: [OpenSpec](https://github.com/Fission-AI/OpenSpec), [Codegraph](https://github.com/colbymchenry/codegraph/blob/main/site/src/content/docs/getting-started/installation.md), [Ponytail](https://github.com/DietrichGebert/ponytail/blob/main/INSTALL.md), [Playwright MCP](https://github.com/microsoft/playwright-mcp), [RTK](https://github.com/rtk-ai/rtk/blob/develop/docs/guide/getting-started/installation.md).

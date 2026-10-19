# OMP engineering workflow

Custom agents and slash commands for requirements, approval, QA and implementation. Shared policy: [RULES.md](RULES.md).

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
| rtk-ai | Reuse a verified `rtk`, otherwise run the official v0.45.0 installer with release checksum verification enforced | Compact command output without losing failure evidence. |

Only Playwright and Context7 need the MCP entries supplied here. Installed tools are verified by actual invocation, not PATH lookup alone. Working CLIs and Ponytail are not automatically upgraded on repeat runs; Playwright is kept at the configured version.

Check actual invocations before starting:

```bash
openspec --help
codegraph --help
rtk --help
```

Read the installed Ponytail skill and confirm the two MCP tool sets are available in OMP. OpenSpec and Ponytail must work before their required stages; unavailable browser automation blocks browser verification. Other fallbacks and evidence requirements are defined in RULES.md.

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

## Roles

| Agent | Responsibility |
| --- | --- |
| interviewer | Ask 1–3 focused questions per round; confirm scope and product/engineering/mixed route. |
| product-manager | Convert product requirements into a business-facing PRD with measurable REQ IDs. |
| tech-lead | Write engineering design and OpenSpec-compatible implementation tasks. |
| qa-engineer | Write traceable TC scenarios after spec approval; independently verify implementation later. |
| security-engineer | Red-team attack-path analysis and blue-team defenses, mitigations and security regression checks. |
| reviewer | Independently review gate inputs and final changes, with concrete evidence. |
| software-engineer | Implement only the approved, reviewed and testable scope. |

Product work requires `prd.md`; engineering work requires `design.md`; mixed work requires both. OpenSpec schema-required artifacts still apply. Extra technical design is required when a product change needs technical decisions.

## Command sequence

Replace `change-slug` with the slug recorded by the interview. Each command stops at its next human gate.

| Step | Command | Result / gate |
| --- | --- | --- |
| Interview | `/work-new <request>` | Inspect context, check dependencies, ask questions, write `interview.md`. |
| Confirm requirements | `/work-review change-slug interview`, then `/work-approve change-slug interview` | Independent review and explicit human confirmation. |
| Specify | `/work-spec change-slug` | Product-manager PRD and/or tech-lead design; OpenSpec proposal and delta specs. |
| Approve scope | `/work-review change-slug spec`, then `/work-approve change-slug spec` | Independent security and reviewer PASS, then human approval of the whole spec bundle before QA planning. |
| QA plan | `/work-qa change-slug` | Positive, negative, boundary and existing-feature regression scenarios. |
| Approve scenarios | `/work-review change-slug test-plan`, then `/work-approve change-slug test-plan` | All requirements covered; explicit human test-plan approval. |
| Plan | `/work-plan change-slug` | Ordered implementation/test tasks linked to REQ/TC IDs. |
| Authorize implementation | `/work-review change-slug tasks`, then `/work-approve change-slug tasks` | Approves full planning bundle; implementation also requires OpenSpec validation. |
| Implement | `/work-implement change-slug` | Smallest complete change and actual test/smoke evidence. |
| Verify | `/work-verify change-slug` | Independent QA, security-engineer and reviewer; per-scenario PASS/FAIL/BLOCKED/NOT_RUN. |
| Close | `/work-archive change-slug` | Requires verification PASS and separate human archive authorization. Does not authorize merge/deploy. |

Use `/work-status change-slug` to inspect freshness and blockers; `/work-resume change-slug` continues only the allowed stage. Calling an approval command requests a decision; it does not itself grant approval.

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
- Aligned all seven agents and eleven commands with the gated lifecycle and six dependency roles, including red-team/blue-team security review.
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
- All seven agent and eleven command frontmatter documents parsed. Actual OMP dispatch found `security-engineer`, which returned BLOCKED for missing spec/manifest inputs without probing systems or writing records.
- The approval-to-archive happy path and application-specific security/browser scenarios were not exercised. macOS installation was not run. The gate smoke demonstrates refusal cases, not guaranteed enforcement.

Installation references: [OpenSpec](https://github.com/Fission-AI/OpenSpec), [Codegraph](https://github.com/colbymchenry/codegraph/blob/main/site/src/content/docs/getting-started/installation.md), [Ponytail](https://github.com/DietrichGebert/ponytail/blob/main/INSTALL.md), [Playwright MCP](https://github.com/microsoft/playwright-mcp), [RTK](https://github.com/rtk-ai/rtk/blob/develop/docs/guide/getting-started/installation.md).

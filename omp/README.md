# OMP engineering workflow

Custom agents and slash commands for human-first product/technical planning, OpenSpec preparation, QA and implementation. Shared policy: [RULES.md](RULES.md).

## Explicit opt-in and scope

The workflow activates before loading lifecycle core/stage/gate policy, only for a custom `/work-*` command, an explicit custom-agent request, or an explicit workflow request. Ordinary questions, unrelated work, repository presence, path/tool mentions and internal helper dispatch do not activate planning or approvals. Ordinary safety, relevant skills and verification still apply.

Activation belongs to the requested operation/change, not the entire session. A direct role performs only its assigned work; `/work-status` and `/work-view` are read-only and do not start planning. Explicit invocation is not approval and cannot bypass an active change's transition prerequisites. See [activation policy](RULES.md) and the canonical [gate protocol](rules/gates.md).

## Context and token efficiency

The workflow must not spend tokens discovering its own configuration. Read only the active command/agent prompt, the short rule index, core rules and rules required for the current stage. Never read every agent, command, skill, template or rule file. OMP already supplies the active prompt; do not reopen it. Load skills and tool documentation only when the task needs them. Use paths, IDs and digests to reference artifacts; read full bodies only when required for the current decision or review. Reuse unchanged context and avoid repeating full documents in handoffs.


The workflow is evidence-first and cost-aware. One primary model authors each stage; use one independent reviewer at required gates, and invoke specialist agents only when risk requires them. Agents enumerate/hash gate-bound inputs, read authoritative inputs needed for their decision, and retrieve supporting material on demand. Handoffs pass paths, manifest identities, REQ/TC IDs and concise findings instead of duplicating documents. This reduces redundant model calls without relaxing human approvals, freshness, coverage or independent final verification.


## Caveman token-efficient communication

The workflow bundles the [Caveman skill](skills/caveman/SKILL.md) from [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman). Shared rules apply its concise style to routine agent communication and handoffs; the skill file is available to OMP under `skills/caveman/`.

**Important distinction:** Caveman is for communication, not human documentation. PRDs, Tech Docs, QA plans, task breakdowns, code/comments, commits and PRs remain clear, professional and self-contained. Agents remove filler, not rationale, requirements, uncertainty, evidence, safety language or technical facts. The installer now requires and links the bundled skill so it cannot silently be absent.

## Model selection and quota-aware operation

The operator chooses the active model per session based on availability. No workflow agent pins a provider or silently switches to a paid route. Child agents inherit the active route unless the operator explicitly configures overrides; workflow work does not authorize persistent settings changes.

Independent review and final QA require separate runs, not different models. Correctly routed author, reviewer and QA runs may use the same operator-authorized free model. Required unavailable dispatch or coverage is BLOCKED/NOT_RUN, never inferred capability; request an operator routing decision rather than silently choosing another provider.

`defaultThinkingLevel: low` and `task.enableEffort: false` reduce default reasoning consumption; raise main effort manually for difficult work. These are not hard cost limits.

## Child-agent effort and delegation

All seven workflow agents are configured with `thinking-level: low`, `advisor: false`, and `spawns: []`. This keeps them on the parent's model route by default, prevents nested delegation/advisor calls, and leaves orchestration and escalation to the main agent. A low-effort result is not automatically trusted: required independent reviews and verification still apply.

Keep per-spawn effort overrides disabled unless intentionally needed. In the active OMP settings file (usually `$HOME/.omp/agent/config.yml`), the relevant setting is:

```yaml
task:
  enableEffort: false
```

This setting is documented by OMP as disabled by default. If it is enabled, a task caller's `effort: hi` can override an agent's configured thinking level. Existing `task.agentModelOverrides` or `modelRoles` settings can also route agents to a different model, so review those if a child still consumes more than expected. Do not replace your entire config file just to apply this snippet.

The main agent should escalate only after a concrete reason: unresolved ambiguity, conflicting evidence, significant implementation risk, or a security-sensitive change. First request a focused correction; use medium/high effort only when needed.

## Install

From the dotfiles repository root:

```bash
bash omp/install-omp.sh
```

Requires Linux or macOS, Node.js **20.19+**, npm, OMP, Git, curl and tar already on PATH. The installer installs missing workflow dependencies, verifies them, then replaces configuration. It never invokes `sudo` or edits your shell profile.

Configuration goes into `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`. Existing `config.yml`, `mcp.json`, `agents/`, `commands/`, `RULES.md`, `rules/` and `templates/` are moved to timestamped backups and replaced with current source links. Matching links remain unchanged. All five document templates and all five stage-rule files are required and checked before dependency installation. The bundled `skills/caveman/` is required and linked; optional `extensions/` is linked only if present.

CLI packages go into `${NPM_CONFIG_PREFIX:-$HOME/.local}`; keep its `bin/` directory first on PATH when starting OMP. The installer prints the exact shell command. Chromium uses Playwright's managed browser cache; Ponytail uses OMP's user plugin store.

The terminal UI shows five real stages with text labels and terminal-palette colors: cyan for stages/running work, green for ready/success, yellow for backups/notices and red for errors. Color is supplementary, not the only status signal. Redirected output, `TERM=dumb` and `NO_COLOR` produce plain text. Full command logs are retained under `<config-dir>/install-logs/`; a failed dependency check stops before configuration replacement.

Start a new OMP session after installation. Explicitly activated operations load the applicable installed shared policy first, then project `.omp/RULES.md` when present. Shared `RULES.md` and `rules/*.md` resolve under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`, not the working directory. Project policy is additive; unreadable required policy blocks the operation.

## Dependencies

| Tool | Delivery | Workflow role |
| --- | --- | --- |
| OpenSpec | Reuse a working CLI, otherwise install `@fission-ai/openspec@1.14.3` | Change lifecycle, schema artifacts, validation and archive. |
| Ponytail | Verify installed skill, otherwise register `DietrichGebert/ponytail` and install its OMP plugin | Smallest complete implementation; no unnecessary abstraction. |
| Codegraph | Reuse a working CLI, otherwise install `@colbymchenry/codegraph@1.6.2` | Source-confirmed impact, callers and regression scope. |
| Playwright | Install/verify `@playwright/mcp@0.0.83`, install its matching Chromium and render a smoke page | Real browser acceptance and regression checks. |
| Context7 | Configure hosted MCP and verify a real MCP initialize response; no local package needed | Current library/API/CLI documentation, matched to installed versions. |
| rtk-ai | Reuse a verified `rtk`, otherwise run the official v0.45.0 installer with release checksum verification enforced | Wrap every shell tool invocation; specialized subcommands, proxy or run. |

Only Playwright and Context7 need the MCP entries supplied here. Installed tools are verified by actual invocation, not PATH lookup alone. Working CLIs and Ponytail are not automatically upgraded on repeat runs; Playwright is kept at the configured version.

Check actual invocations before starting:

```bash
rtk proxy openspec --help
rtk proxy codegraph --help
rtk --help
```

Read the installed Ponytail skill and confirm the two MCP tool sets are available in OMP. OpenSpec and Ponytail must work before their required stages; unavailable browser automation blocks browser verification. Other fallbacks and evidence requirements are defined in RULES.md.

### Shell commands

Every shell tool invocation goes through `rtk`:

| Route | Use |
| --- | --- |
| `rtk <subcommand>` | Preferred for supported tools: `rtk git status`, `rtk grep`, `rtk test`, `rtk playwright`. |
| `rtk proxy <command> [args]` | Specialized route rejects required flags, hides needed failure detail, or the command is unsupported. |
| `rtk run '<shell command>'` | Pipelines, redirection or compound shell syntax. |

File read/search/edit tools remain preferred over shell. Preserve exit status and raw failure output; RTK compression is not verification. If RTK is unavailable, shell execution is blocked rather than run natively. `rtk gain -p` reports adoption or output reduction, not correctness or total model-token savings. Universal routing lives in `rules/core.md`, so it applies during planning as well as execution.

### Context7 and Ponytail

Use Context7 for relevant external library/framework/SDK/API/CLI/service documentation questions: resolve the library ID, then query the specific topic. An exact supplied Context7 ID skips resolution. Match installed versions when supported, record sources/version limitations, never send private code or secrets, and reuse current applicable results. If unavailable, disclose authoritative-doc fallbacks; material unresolved decisions block progress. An enabled MCP entry or successful initialize handshake alone is not proof of documentation retrieval.

Read installed Ponytail before implementation for the smallest complete solution. Caveman is required for conversation, not human documents; use relevant Antislop variants for prose, comments or UI without unrelated UI setup. Prefer available language-server symbol intelligence and Codegraph for nontrivial impact, confirming callers and regression scope in source. Reuse unchanged guidance already read in the same session; fresh children read their needed inputs. No tool runs merely to fill a checklist.


### Use by stage

| Stage | Use when relevant | Evidence |
| --- | --- | --- |
| Discovery/human planning | Repository instructions, current source/callers/tests/docs; read-only schema preflight if needed | Confirmed facts, decisions, rationale and blockers |
| Execution preparation | Installed OpenSpec schema/validation; Codegraph/LSP for nontrivial impact; Context7 for external documentation questions | Linked specs, QA scenarios and schema tasks; actual results and limitations |
| Implement | Ponytail; relevant source intelligence and external docs; targeted checks at coordinated stable checkpoints | Smallest complete solution; author evidence is not independent QA |
| Verify | OpenSpec validation; actual project tests and changed-path smoke; actual Playwright for browser changes | Commands, exit codes, observed outcomes and independent QA/reviewer verdicts |
| Security | Security-engineer only for security-sensitive scope or a credible risk | Attack paths, mitigations and evidence |

Do not invoke a tool solely to fill an evidence checklist. Record each actual invocation and result; mark genuinely inapplicable tools N/A with a short reason. Never claim a tool ran when it did not.

Installation boundaries:

- Node/npm/OMP and platform tools are prerequisites, not bootstrapped. No nodenv/global Node version changes.
- Installation requires npm/GitHub downloads and Context7 connectivity. Package managers and the official RTK installer execute upstream code; RTK's downloaded release archive is checksum-verified. No repository indexing or project `openspec init` runs automatically.
- Chromium no longer uses a machine-specific executable path. The existing `--no-sandbox` policy remains explicit in config and installer output: use trusted test content or an isolated environment.
- Linux may need Chromium OS libraries. Browser launch errors remain in the full log; install the reported platform libraries and rerun rather than treating a browser download as a successful launch.


### Modular shared rules

- `RULES.md` decides activation before loading workflow-specific rules.
- Activated operations load core and only their applicable stage rules; approval transitions use the canonical protocol in `rules/gates.md`.
- Direct roles load policy relevant to assigned work, not a complete planning pipeline. Status/view remain read-only.

## Efficiency and adaptive effort

`/work-new` classifies each change as **focused** or **full** and records the rationale in `interview.md`. Focused is for localized, low-risk, behavior-preserving engineering work: short Tech Doc and task breakdown, targeted repository inspection and compact handoffs. Full is for new behavior, migrations, cross-module or security-sensitive work and uncertain impact. Escalate focused to full when evidence reveals broader risk.

Both modes preserve human approval, required gate review, OpenSpec validation, QA planning and independent final verification. Focused mode reduces document verbosity, unnecessary tool calls and specialist fan-out; it is not a gate bypass. Security-engineer review is mandatory only for security-sensitive scope or credible risks; otherwise the reviewer records why it is not applicable. Reuse unchanged artifacts within a session and measure actual token/call/time data before claiming savings.

### Smallest complete change

Agents solve the stated requirement with the least new structure: reuse existing patterns and dependencies, and add no speculative abstraction, configuration, agent, command or duplicated policy. Complexity must trace to an approved requirement or observed evidence; reviewers may require removal even when tests pass. The canonical rule is in [core.md](rules/core.md).

## Human-first command sequence

There are exactly two routine pre-build approval targets: `human-planning` and `execution`. [Canonical gates](rules/gates.md) define manifests, review/decision handling and transitions; the sequence below is a navigation guide, not another protocol.

| Step | Command | Output and boundary |
| --- | --- | --- |
| Discover | `/work-new <request>` | Inspect current source/docs/tests, use built-in `ask` for material choices and record interview decisions. Interview confirmation is not a separate approval gate. |
| Human planning | `/work-product-plan <slug>` when applicable; `/work-tech-plan <slug>` | Reuse/update applicable PRD, design and human task breakdown proportionally. Read-only schema preflight is allowed; no generated specs yet. |
| Human checkpoint | `/work-doc-review <slug>` | Independently review interview plus applicable PRD/design and human task breakdown together; request `human-planning` approval of the immutable input manifest. |
| Execution preparation | `/work-prepare <slug>` | After human approval, derive schema proposal/specs, QA plan and executable tasks together. `/work-qa` and `/work-plan` populate this bundle, without separate approval checkpoints. |
| Execution checkpoint | `/work-review <slug> execution`; `/work-approve <slug> execution` | Independent full-bundle review, risk-required security review, successful schema validation and explicit `execution` approval before code. |
| Implement | `/work-implement <slug>` | Complete approved tasks/callers/tests/docs; coordinate targeted checks at stable checkpoints without racing shared edits. |
| Independently verify | `/work-verify <slug>` | Separate QA and final reviewer runs, plus risk-required security specialist; current actual results and changed-path smoke. |
| Finish | Review-ready handoff | Present documents, changes, evidence, identities and remaining risks; await human review/acceptance without taking external actions. |
| Optional administration | Explicit `/work-archive <slug>` request | Separate archive authorization and current prerequisites; never implicit PR, merge, release or deployment permission. |

`task-breakdown.md` is the human milestone plan; schema `tasks.md` is its linked executable checklist, not a second competing plan. Human documents remain authoritative. Material gaps or contradictions discovered during preparation reopen affected planning rather than silently adding behavior.

Inspect source before asking questions. Present concrete consequences, options and a recommendation through built-in `ask`, support custom input, challenge risky choices with source-backed evidence, and record the selected rationale automatically. If `ask` is unavailable, disclose that and use numbered questions. Do not repeat settled questions without material new evidence or changed intent.

## Document templates

| Template | Output / author | Command |
| --- | --- | --- |
| [PRD](templates/PRD.md) | `prd.md` / product-manager | `/work-product-plan <slug>` |
| [Tech Doc](templates/TECH-DOC.md) | `design.md` / tech-lead | `/work-tech-plan <slug>` |
| [QA Test Case Scenarios](templates/QA-TEST-CASES.md) | `test-plan.md` / qa-engineer | Execution preparation after `human-planning` approval |
| [Human Task Breakdown](templates/HUMAN-TASK-BREAKDOWN.md) | `task-breakdown.md` / tech-lead | `/work-tech-plan <slug>` |
| [Agent Task Checklist](templates/TASK-BREAKDOWN.md) | `tasks.md` / tech-lead | Execution preparation alongside QA, before `execution` approval |

Adapted from the supplied EVA document templates and embedded QA scenarios, retaining structure rather than EVA-specific repositories, frameworks, tenant policies or CRUD ordering. They use short sections, observable acceptance criteria and stable REQ/TC/SEC/task links.

Reuse existing source-backed human documents and milestones before drafting new ones. Read project `.omp/templates/<filename>` first, then installed `templates/` as fallback when a template is needed; missing optional scaffolding does not block a complete existing document. Keep applicable professional detail and mark inapplicable concerns with reasons instead of forcing application-specific sections.

The installed OpenSpec schema takes precedence for required headings and checkbox grammar. Templates guide content, not mandatory duplicate artifacts/checklists. Preserve complete REQ/TC/security and affected-feature regression coverage; planned commands and examples are not runtime evidence. QA execution results and progress belong in existing `verification.md`, not the frozen approved plan.

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
| interviewer | Inspect source first; use built-in `ask` for concrete choices, challenge with evidence, and record decisions/rationale without repeating settled questions. |
| product-manager | Convert product requirements into a business-facing PRD with measurable REQ IDs. |
| tech-lead | Reuse/write human design and milestones, then derive schema specs/tasks alongside QA in combined execution preparation. |
| qa-engineer | Populate traceable QA scenarios in execution preparation; independently verify implementation in a separate run later. |
| security-engineer | Red-team attack-path analysis and blue-team defenses, mitigations and security regression checks. |
| reviewer | Independently review gate inputs and final changes, with concrete evidence. |
| software-engineer | Implement only the approved, reviewed and testable scope. |

Product work requires `prd.md`; engineering work requires `design.md`; mixed work requires both. OpenSpec schema-required artifacts still apply. Extra technical design is required when a product change needs technical decisions.

### Ownership and review

A continuing informed author may carry related authoring stages forward using digest-current inputs. Independent reviewers inspect their own authoritative inputs; final QA and final reviewer are separate runs from implementers and each other. Security-sensitive scope or credible risk requires a security specialist; otherwise record why it is inapplicable.

Targeted author checks may run once owned inputs are stable and no shared-edit race exists. Record real failures and repairs; these checks do not self-certify QA. Final readiness requires current required scenarios, changed-path smoke and independent verdicts, with no unresolved blocking finding. Required FAIL/BLOCKED/NOT_RUN prevents readiness.

Every author returns `Gate`, `Artifacts`, `Evidence`, `Open questions`, `Next`. The orchestrator applies the [canonical gate protocol](rules/gates.md), presents the actual bundle and records only an explicit human decision. `/work-review <slug> <target>` and `/work-approve <slug> <target>` use `human-planning` or `execution`; administrative `archive` remains separate. `/work-status` reports evidence/freshness, blocker and one next action; `/work-resume` rechecks prerequisites rather than inferring approval.

### Approval identity and legacy work

Human-planning inputs are the interview, applicable PRD/design and human task breakdown. Execution inputs include that approved bundle, change configuration and installed schema inputs, proposal/specifications, QA plan and schema tasks. Reviews and decisions bind immutable sorted path/SHA-256 manifests; mutable ledgers, execution progress and project authoring guides such as `omp/templates/` stay outside normative approval inputs. Record supporting guide/source identities separately.

Added, deleted or changed relevant inputs invalidate affected and dependent approval/evidence. Retain append-only history; reuse unchanged evidence only after proving freshness/equivalence. Freeze approved task wording and boxes during implementation; record progress in `verification.md`. Final source identity includes relevant dirty/untracked/deleted files, not HEAD alone.

Legacy approvals do not alias new targets. Inspect current artifacts/history, independently review coverage and the proposed mapping, then obtain an explicit human decision binding the mapped current bundle. Incomplete human coverage returns to human planning; incomplete derived coverage returns to execution preparation. Preserve old records and never infer implementation permission from old target names.

### Review-ready is not acceptance

The final package links documents, changed behavior/contracts/files, task completion, actual commands/exits, TC outcomes, independent findings, current planning/source identities and risks. Agent readiness does not establish human acceptance. Only explicit human acceptance closes acceptance accounting; silence, an approval to build or a review-ready verdict does not.

PR creation, archive, deployment, merge and release require separate requests and authorization. Missing independent dispatch/evidence blocks readiness rather than permitting self-review.

These gates are prompt-level policy, not executable access control. This configuration does not ship a gate script or write-blocking hook. OpenSpec validation checks schema/spec structure, not human approval or software correctness.

## Readable artifacts

All change artifacts live under `openspec/changes/<slug>/`. Use short sections, bullets, compact tables and paragraphs of at most three sentences. Keep confirmed facts separate from assumptions and blockers.

A test scenario should fit in one row:

| TC | REQ | Given | When | Then | Layer |
| --- | --- | --- | --- | --- | --- |
| TC-001 | REQ-001 | An existing authorized user | They submit valid input | The specified change persists and appears after reload | Integration/browser |

This row illustrates the format, not a requirement for your application. Real scenarios must come from approved requirements and repository behavior.

### Correction and usage accounting

Use a compact metric section inside the existing change `verification.md`; no extra template, parser, telemetry service or dashboard is required. This is a record shape, not a claim that runtime capture exists. Use available evidence and write `unknown` when attribution or a baseline is unavailable.

The canonical field set, classification and counting rules live in `rules/verification.md` under "Correction-cycle accounting": `raw revisits`, `avoidable revisits`, `raw total tokens`, `avoidable subtotal`, `first-pass acceptance`, `elapsed time`, `evidence coverage`. Record each revisit's category, affected REQ/TC, prompt and request IDs, and cycle boundary; count each provider request once.

RTK output reduction measures neither full-cycle model tokens nor correction savings. Preserve necessary questions and raw corrections rather than optimizing the apparent prompt count. Separate same-model runs can be independent; model/provider differences alone do not prove independence.

## Configuration changes

- Repaired modular `rules/` deployment and made installed shared policy mandatory before additive project policy across all seven roles and fifteen commands.
- Centralized universal RTK routing and Context7 resolve/query evidence in core policy; made Ponytail mandatory before implementation with unchanged same-session reuse.
- Replaced references to a nonexistent gate script with one explicit review/approval/freshness protocol.
- Aligned all seven agents and fifteen commands with the gated lifecycle; OpenSpec preparation uses one primary author and security-specialist review is risk-based to avoid redundant model calls on routine changes.
- Fixed installation of workflow rules and handling of absent optional directories.
- Replaced stale agent, template and MCP documentation with the current configuration.
- Added dependency installation/verification and a staged, theme-native terminal UI with plain-text fallback and retained failure logs.
- Added four reusable document templates, required installation and gated author/command integration; added semantic installer colors without changing plain-text behavior.

## Historical verification

These observations concern earlier revisions and fixtures, not proof of the revised two-bundle workflow. Legacy target names below are historical commands, not supported aliases or current approval authority. Current change evidence belongs in its `verification.md`; this documentation update adds no runtime result.

- Agent-tool-policy repair: `rtk proxy bash omp/tests/install-rules.sh` exercised the actual deployment block in temporary directories. Fresh install, sentinel preservation, occupied backup collision and matching-link repeat passed; all five installed rule files were readable. No dependency setup or live installation ran.
- Installer/regression Bash syntax and strict OpenSpec validation passed. A raw `rtk proxy` failure probe preserved stderr marker `OMP_RTK_FAILURE_PROBE` and exit 7. Context7 resolve/query retrieval is recorded in `openspec/changes/align-agent-tool-policy/interview.md`; this proves parent-session retrieval, not future child availability.
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

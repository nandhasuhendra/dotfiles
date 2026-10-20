# OMP workflow rules entry point

Shared policy base: `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`. Resolve this `RULES.md` and every shared `rules/*.md` path below against that base, never the working directory. Always read the shared entrypoint and `rules/core.md`, then only the applicable stage rules. Also read repository `.omp/RULES.md` when present: it supplements shared policy and may strengthen, never bypass, its gates. Stop if any required shared or applicable project policy cannot be read.

## Context-loading budget

- Read only the active command/agent prompt, this index, core policy, and the stage/gate rules needed now. OMP already supplies the active prompt; never reopen it just to reread it.
- Never enumerate/read all agents, commands, skills, templates, rules, or project docs as a ritual. Open another file only when the current decision needs it.
- Skills and tools are opt-in by relevance. Do not read Caveman, Ponytail, tool help, or dependency docs when the current task does not need them.
- For change artifacts, inspect paths, sizes and digests first. Read full bodies only for the specific requirements, decisions, evidence or review being performed; use links/IDs/manifests for the rest.
- Reuse unchanged content already in context. Recompute identity/freshness cheaply; do not reread unchanged bodies merely to prove they still exist.
- Do not paste rules, skills, prompts or documents into child-agent handoffs when they can read the canonical file by path. Pass the minimum paths, IDs, decisions and evidence needed.

| Stage / command | Additional rules |
|---|---|
| Interview, `work-new`, product plan, tech plan, human doc review, OpenSpec preparation, QA planning, task planning | `rules/planning.md`; load `rules/gates.md` when handling approvals or transitions |
| Implementation and repository changes | `rules/execution.md`; load `rules/gates.md` when handling approvals or transitions |
| QA execution, `work-verify`, security review, `work-archive` | `rules/execution.md`, `rules/verification.md`, and `rules/gates.md` |
| Status, resume, view, approve, standalone review | `rules/core.md` plus `rules/gates.md` for approval/status decisions; load a relevant stage file only when needed |

## Universal invariants

- Human planning documents are the source of truth. Do not create OpenSpec specifications until the complete applicable human document bundle has passed independent review and explicit human approval.
- Never infer human approval, reviewer PASS, tool execution, test success or evidence freshness. Missing, stale, failed, blocked or unrun evidence is not PASS.
- Preserve independent reviews, explicit approvals, REQ/TC traceability, security and regression coverage, source/artifact manifests, and verification integrity in every effort mode.
- Focused mode reduces verbosity and irrelevant exploration only; it never bypasses gates. If risk, uncertainty or scope expands, escalate to full mode.
- Do not overwrite an existing change to start another. Use `openspec/changes/<slug>/` and a kebab-case slug.
- No application code, production configuration, migrations or implementation tests before the implementation gate. Reading source and running existing checks are allowed.
- When a rule conflicts, apply the stricter safety/approval requirement and surface the conflict rather than silently bypassing it.

For complete policy, follow the stage map above. Keep this entry point short so every agent can discover relevant rules without paying to load unrelated stage details.

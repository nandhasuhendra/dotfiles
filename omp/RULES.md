# OMP workflow rules entry point

## Applicability — check before loading workflow rules

Activate this workflow only for a user-invoked `/work-*` command, an explicit request to use this workflow, or an explicit request for a custom agent. A custom agent performs only its requested role; it does not start the whole lifecycle. `/work-status` and `/work-view` inspect only. Internal helper dispatch, ordinary/simple/non-project prompts, repository presence, and mentions of `omp/`, skills or tools do not activate it. Scope activation to the requested operation/change; do not carry it into unrelated requests.

Without activation, stop workflow loading here: no `rules/core.md`, stage/gate rules, change scaffolding, or workflow approval ritual. Ordinary safety, project instructions, and independently supplied universal tool policies still apply. Explicit invocation is never approval and cannot bypass prerequisites for a requested active-change transition.

When active, shared policy base is `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`. Resolve this `RULES.md` and shared `rules/*.md` against that base, never the working directory. Read `rules/core.md`, then only applicable stage rules. Read repository `.omp/RULES.md` when present; it may strengthen, never bypass, gates. Stop if a required policy cannot be read.

## Context-loading budget

- Read only the active command/agent prompt, this index, core policy, and the stage/gate rules needed now. OMP already supplies the active prompt; never reopen it just to reread it.
- Never enumerate/read all agents, commands, skills, templates, rules, or project docs as a ritual. Open another file only when the current decision needs it.
- Caveman skill is REQUIRED, exclude for document content.
- Skills and tools are opt-in by relevance. Do not read Ponytail, tool help, or dependency docs when the current task does not need them.
- For change artifacts, inspect paths, sizes and digests first. Read full bodies only for the specific requirements, decisions, evidence or review being performed; use links/IDs/manifests for the rest.
- Reuse unchanged content already in context. Recompute identity/freshness cheaply; do not reread unchanged bodies merely to prove they still exist.
- Do not paste rules, skills, prompts or documents into child-agent handoffs when they can read the canonical file by path. Pass the minimum paths, IDs, decisions and evidence needed.

| Operation | Additional rules |
| --- | --- |
| Interview, product plan, tech plan, human document review | `rules/planning.md`; add `rules/gates.md` when preparing or recording `human-planning` approval |
| OpenSpec preparation, QA planning, task planning | `rules/planning.md` and `rules/gates.md`; contribute to one `execution` bundle |
| Implementation and repository changes | `rules/execution.md`; add `rules/gates.md` when checking transitions |
| Verification, security review, archive | `rules/execution.md`, `rules/verification.md`, `rules/gates.md` |
| Status, resume, view, approve, standalone review | `rules/core.md` plus `rules/gates.md`; add a stage file only when needed |

## Active-workflow invariants

- Human planning documents are the source of truth. Do not create OpenSpec specifications until the complete applicable human document bundle has passed independent review and explicit human approval.
- Never infer human approval, reviewer PASS, tool execution, test success or evidence freshness. Missing, stale, failed, blocked or unrun evidence is not PASS. A free-text "implement", "go ahead" or "proceed" message is not an approval: refuse it, name the missing obligation and give the one command that obtains it.
- Preserve independent reviews, explicit approvals, REQ/TC traceability, security and regression coverage, source/artifact manifests, and verification integrity in every effort mode.
- Focused mode reduces verbosity and irrelevant exploration only; it never bypasses gates. If risk, uncertainty or scope expands, escalate to full mode.
- Smallest complete change: solve the stated requirement with the least new structure. No speculative abstraction, configuration, agent, command or duplicated policy; see `rules/core.md`.
- Do not overwrite an existing change to start another. Use `openspec/changes/<slug>/` and a kebab-case slug.
- No application code, production configuration, migrations or implementation tests before reviewed `execution` approval. Reading source and running existing checks are allowed.
- When a rule conflicts, apply the stricter safety/approval requirement and surface the conflict rather than silently bypassing it.

For complete policy, follow the stage map above. Keep this entry point short so every agent can discover relevant rules without paying to load unrelated stage details.

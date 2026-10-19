# OMP workflow rules entry point

Read `omp/RULES.md` (this file) and `rules/core.md` for every stage. Then load only the applicable stage rule(s) below; do not load every rules file by default. Project `.omp/RULES.md` may strengthen these rules but must not silently bypass gates.

| Stage / command | Additional rules |
|---|---|
| Interview, `work-new`, product plan, tech plan, human doc review, OpenSpec preparation, QA planning, task planning | `rules/planning.md` |
| Implementation and repository changes | `rules/execution.md` |
| QA execution, `work-verify`, security review, `work-archive` | `rules/execution.md` and `rules/verification.md` |
| Status, resume, view, approve, standalone review | `rules/core.md` plus the specific gate's relevant stage file only when needed |

## Universal invariants

- Human planning documents are the source of truth. Do not create OpenSpec specifications until the complete applicable human document bundle has passed independent review and explicit human approval.
- Never infer human approval, reviewer PASS, tool execution, test success or evidence freshness. Missing, stale, failed, blocked or unrun evidence is not PASS.
- Preserve independent reviews, explicit approvals, REQ/TC traceability, security and regression coverage, source/artifact manifests, and verification integrity in every effort mode.
- Focused mode reduces verbosity and irrelevant exploration only; it never bypasses gates. If risk, uncertainty or scope expands, escalate to full mode.
- Do not overwrite an existing change to start another. Use `openspec/changes/<slug>/` and a kebab-case slug.
- No application code, production configuration, migrations or implementation tests before the implementation gate. Reading source and running existing checks are allowed.
- When a rule conflicts, apply the stricter safety/approval requirement and surface the conflict rather than silently bypassing it.

For complete policy, follow the stage map above. Keep this entry point short so every agent can discover relevant rules without paying to load unrelated stage details.

# OMP Model Routing

## Routing policy

Routing is role-based and adaptive to the work being performed. The primary model is selected by the role assigned to the task; OMP retry fallback chains handle provider/model failures. Fallback is availability recovery, not an answer-quality evaluator.

The active provider set is Z.ai Coding Plan (zai), OpenCode Go (opencode-go), and OpenRouter (openrouter). Do not reintroduce retired Codex, Antigravity, or OpenCode Zen selectors unless the provider setup changes deliberately.

All selectors and fallback chains live in omp/config.yml. Agent frontmatter describes responsibility and thinking preference, not provider/model IDs. File-based slash commands expand into the active parent session; their body text does not select a model. task.agentModelOverrides routes spawned agents only. Therefore /work-spec and /work-human explicitly delegate heavy planning/synthesis to tech-lead, while /work-build delegates implementation to software-engineer. The parent session remains on its active/default model and retains user interaction and approval gates.

## Role map

| Workload | OMP role | Primary | Thinking | Rationale |
| --- | --- | --- | --- | --- |
| Main/default session and routine orchestration | default | OpenCode Go GLM-5.3-Flash | low | High-volume routine work without spending Z.ai quota. |
| Product/specification and technical design | doc_tier | Z.ai GLM-5.2 | medium | Reserve Z.ai Coding Plan for high-value reasoning. |
| Implementation | execution_tier | OpenCode Go GLM-5.3-Flash | low | Cost-efficient coding workhorse. |
| Independent code review | review_tier | OpenCode Go GLM-5.3 | low | Different model from implementation; Z.ai is the next fallback. |
| QA execution | qa_tier | OpenCode Go GLM-5.3-Flash | low | Efficient test planning and verification. |
| Security assessment | security_tier | Z.ai GLM-5.2 | medium | Reserve stronger reasoning for threat and control analysis. |
| Commit message / changelog generation | commit | OpenRouter NVIDIA Nemotron 3.5 Lightning (free) | provider default | Uses OMP built-in commit role; keeps commit text generation off paid coding-plan quota. |

### Model availability note

OMP provider ID for OpenCode Go is opencode-go; for Z.ai Coding Plan it is zai. Selected OpenCode Go model IDs are glm-5.3-flash and glm-5.3.

This configuration deliberately uses zai/glm-5.2 for Z.ai reasoning. The OMP bundled catalog has had a GLM-5.3 catalog gap for zai; do not switch to zai/glm-5.3 or assume a Z.ai Flash variant is selectable until omp models --kind chat on the target installation confirms it. Once the bundled catalog exposes GLM-5.3, update the selector and this note in a separate change.

## Agent assignments

| Agent | Role | Notes |
| --- | --- | --- |
| tech-lead | @doc_tier | Owns specification and technical design work. |
| software-engineer | @execution_tier | Implements approved tasks; may dispatch only its allowed quality agents. |
| code-reviewer | @review_tier | Independent, read-only review. |
| qa-engineer | @qa_tier | Independent, read-only behavior verification. |
| security-engineer | @security_tier | Explicitly dispatched for security-sensitive changes or credible risks. |
| principal-engineer | @doc_tier | Independent senior design review of `/work-spec` artifacts before Gate 2 and of existing docs for `/review-docs`. |
| pattern-reviewer | @review_tier | Read-only structural review for `/review-patterns` and `/review-all`. |
| performance-engineer | @review_tier | Read-only performance and scalability review for `/review-performance` and `/review-all`. |
| security-audit-recon | @review_tier | Read-only reconnaissance and coverage critics for `/security-audit`. |
| security-audit-hunter | @security_tier | Read-only coverage-led hunting; one structured result per assignment. |
| security-audit-verifier | @security_tier | Independent candidate and final-record verification. |

The built-in sonic agent remains on @execution_tier. Do not configure overrides for custom agents that do not exist in omp/agents/.

## Fallback policy

Fallback order is defined per role in config.yml and deliberately prioritizes provider diversity and quota protection:

- Default: OpenRouter free Nemotron → OpenCode Go GLM-5.3.
- Documentation: OpenCode Go GLM-5.3 → OpenRouter free Nemotron.
- Execution: OpenRouter free Nemotron → OpenCode Go GLM-5.3.
- Review: Z.ai GLM-5.2 → OpenRouter free Nemotron.
- QA: OpenRouter free Nemotron → OpenCode Go GLM-5.3.
- Security: OpenCode Go GLM-5.3 → OpenRouter free Nemotron.
- Commit: OpenRouter free Inkling after OpenRouter free Nemotron.

The high-volume default, execution and QA paths do not fall back to Z.ai. This is intentional: a Go quota failure should not silently consume the Z.ai Coding Plan. Documentation and security may use Z.ai first because those workloads justify the stronger reasoning budget.

retry.fallbackOn is set to any to preserve provider-outage recovery as well as quota recovery. It can also move to a fallback for non-quota provider errors; fallback chains are therefore short and bounded. OpenRouter free models are best-effort and may be rate-limited or unavailable. A successful fallback response is not proof of correctness or quality.

## Token and quality policy

1. Keep routine child-agent thinking low. Use medium only for specification/design and security workloads.
2. Keep task.enableEffort false; task-level effort should not silently inflate model cost.
3. Use OMP built-in commit role for commit/changelog text generation; its primary and fallback are both OpenRouter free models. Do not add a custom commit_tier alias or assume every Git operation is delegated to that model.
4. Do not spawn agents for routine subtasks. The implementation agent may dispatch independent reviewer and QA agents after implementation.
5. Review changed code plus minimum surrounding context. QA executes a focused test matrix; neither agent should reread the whole repository.
6. Pass exact artifact paths, target scope, acceptance criteria and concise handoff context. Do not copy unrelated conversation history.
7. Keep review independent from implementation by using a different primary model. For high-risk changes, explicitly dispatch the security agent.
8. Security assessment is risk-triggered, not an always-on extra agent for routine low-risk changes.
9. OpenRouter free is a cost-saving route, not a guaranteed capacity tier. Do not treat it as the only quality-critical path.

## Verification

Run locally after installation or changing model configuration:

```bash
omp models --kind chat
omp config list
bash omp/tests/token-budget.sh 24
```

Verify:

- Every configured selector resolves in the installed model catalog and has credentials.
- Z.ai resolves zai/glm-5.2; OpenCode Go resolves both opencode-go/glm-5.3-flash and opencode-go/glm-5.3.
- OpenRouter free selectors resolve and are actually marked free in the catalog.
- Every custom agent in omp/agents/ resolves to the intended role.
- The built-in commit role resolves to an OpenRouter free model.
- Fallback chains are accepted by the installed OMP version.
- Provider fallback is tested only when safe and available; never paste credentials into diagnostics.

A model returning a response does not establish that its work meets the task acceptance criteria. Review, QA and security gates remain evidence-based.

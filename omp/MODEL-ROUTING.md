# OMP Model Routing

## Routing policy

Routing is **role-based and adaptive to the work being performed**, not a single model pinned to every agent. The primary model is selected by the role assigned to the task; OMP's retry fallback chain handles provider/model failures. Fallback is availability recovery, not an answer-quality evaluator.

All selectors and fallback chains live in `omp/config.yml`. Agent frontmatter describes responsibility and thinking preference, not provider/model IDs. File-based slash commands expand into the active parent session; their body text does not select a model. `task.agentModelOverrides` routes spawned agents only. Therefore `/work-spec` and `/work-human` explicitly delegate heavy planning/synthesis to `tech-lead`, while `/work-build` delegates implementation to `software-engineer`. The parent session remains on its active/default model and retains user interaction and approval gates.

## Role map

| Workload | OMP role | Primary | Thinking | Rationale |
| --- | --- | --- | --- | --- |
| Product/specification and technical design | `doc_tier` | Codex GPT-5.6 Sol | medium | Higher-value reasoning for requirements, architecture and contracts. |
| Implementation | `execution_tier` | OpenCode Zen DeepSeek V4.1 Flash Free | low | Cost-efficient execution for bounded coding tasks. |
| Independent code review | `review_tier` | Gemini 3.8 Flash | low | Different provider from the implementation primary. |
| QA execution | `qa_tier` | OpenCode Zen DeepSeek V4.1 Flash Free | low | Efficient test planning and evidence reporting. |
| Security assessment | `security_tier` | Codex GPT-5.6 Sol | medium | Reserve stronger reasoning for threat and control analysis. |
| Main/default session | `default` | Codex GPT-5.6 Sol | low | Preserve the existing interactive default; fall back across providers on quota/provider failures. |

## Agent assignments

| Agent | Role | Notes |
| --- | --- | --- |
| `tech-lead` | `@doc_tier` | Owns specification and technical design work. |
| `software-engineer` | `@execution_tier` | Implements approved tasks; may dispatch only its allowed quality agents. |
| `code-reviewer` | `@review_tier` | Independent, read-only review. |
| `qa-engineer` | `@qa_tier` | Independent, read-only behavior verification. |
| `security-engineer` | `@security_tier` | Explicitly dispatched for security-sensitive changes or credible risks. |

The built-in `sonic` agent remains on `@execution_tier`. Do not configure overrides for custom agents that do not exist in `omp/agents/`.

## Fallback policy

Fallback order is defined per role in `config.yml` and deliberately crosses providers:

- Default session: Gemini → Zen → OpenRouter.
- Documentation: Gemini → Zen → OpenRouter.
- Execution: Gemini → Codex → OpenRouter.
- Review: Codex → Zen → OpenRouter.
- QA: Gemini → Codex → OpenRouter.
- Security: Gemini → Zen → OpenRouter.

The configured chains contain selectors already present in the repository's prior routing configuration. Their availability is not guaranteed: verify selectors against the installed catalog before relying on them.

OMP fallback behavior is governed by `retry.fallbackChains`, `retry.modelFallback`, `retry.fallbackOn` and related retry settings. A role's chain is used by agents assigned that role; task model overrides take precedence over agent frontmatter model declarations. Do not add a second custom fallback mechanism.

## Token and quality policy

1. Keep routine child-agent thinking low. Use medium only for specification/design and security workloads.
2. Keep `task.enableEffort: false`; task-level effort should not silently inflate model cost.
3. Do not spawn agents for routine subtasks. The implementation agent may dispatch independent reviewer and QA agents after implementation.
4. Review changed code plus minimum surrounding context. QA executes a focused test matrix; neither agent should reread the whole repository.
5. Pass exact artifact paths, target scope, acceptance criteria and concise handoff context. Do not copy unrelated conversation history.
6. Keep review independent from implementation by using a different primary provider.
7. OpenRouter free models are last-resort availability fallbacks. A successful fallback response is not proof of correctness or quality.
8. Security assessment is risk-triggered, not an always-on extra agent for routine low-risk changes.

## Verification

Run locally after installation or changing model configuration:

```bash
omp models --kind chat
omp config list
bash omp/tests/token-budget.sh 24
```

Verify:

- Every configured selector resolves in the installed model catalog.
- All five custom agents resolve to the intended role.
- No stale agent override exists.
- Fallback chains are accepted by the installed OMP version.
- Provider fallback is tested only when safe and available; never paste credentials into diagnostics.

A model returning a response does not establish that its work meets the task's acceptance criteria. Review, QA and security gates remain evidence-based.

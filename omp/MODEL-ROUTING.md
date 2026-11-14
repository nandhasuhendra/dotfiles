# OMP Model Routing

## Goals

- Preserve Codex quota for genuinely high-value reasoning.
- Use Gemini Flash as the general-purpose planning and review model.
- Use OpenCode Zen DeepSeek Flash for routine implementation and QA.
- Keep OpenRouter free models as last-resort availability fallbacks, not trusted primary reviewers.
- Keep routing centralized in `omp/config.yml`; agent files describe responsibilities, not provider IDs.

## Workload routing

| Workload | Primary | Thinking | Fallback order |
| --- | --- | --- | --- |
| Default / orchestration | Gemini 3.8 Flash | low | DeepSeek Flash Free → OpenRouter Nemotron Free |
| `/work-spec`, `/work-human` | Gemini 3.8 Flash | medium | Codex GPT-5.6 Sol → DeepSeek Flash Free → OpenRouter |
| `/work-build` implementation | DeepSeek V4.1 Flash Free | low | Gemini 3.8 Flash → OpenRouter |
| Code review | Gemini 3.8 Flash | low | DeepSeek Flash Free → OpenRouter |
| QA | DeepSeek V4.1 Flash Free | low | Gemini 3.8 Flash → OpenRouter |
| Security engineer | Codex GPT-5.6 Sol | medium | Gemini 3.8 Flash → DeepSeek Flash Free → OpenRouter |

Model selectors are copied from the existing OMP config where possible. Confirm every selector exists in the local catalog with `omp models --kind chat`; provider availability, quotas and free-model access can change. If a selector is absent, replace it with an exact selector from that command before relying on the route.

## Agent role map

- `interviewer`, `product-manager`, `tech-lead` → `@doc_tier`
- `software-engineer`, `sonic` → `@execution_tier`
- `code-reviewer`, `reviewer` → `@review_tier`
- `qa-engineer` → `@qa_tier`
- `security-engineer` → `@security_tier`

The mappings live in `task.agentModelOverrides`. Do not add overrides for agents that do not exist in this repository. Do not set provider IDs in agent frontmatter unless an agent intentionally needs a pinned exception.

## Token and quota policy

1. Keep the default thinking level at `low`; only planning and security roles use `medium`.
2. Keep `task.enableEffort: false` so agents do not independently inflate effort.
3. Do not spawn agents for routine subtasks. The implementation agent may batch the independent code-reviewer and QA agents after implementation.
4. Review only changed files plus the minimum surrounding context. QA should run the focused test matrix, not re-read the whole repository.
5. Pass concise task context and exact artifact/file paths. Avoid copying entire conversation histories or unrelated OpenSpec changes into child tasks.
6. Use Codex for security review or when Gemini/DeepSeek cannot resolve a concrete architecture/correctness issue. Do not use Codex as the routine fallback for every execution or review task.
7. OpenRouter free models are availability fallbacks only. If a fallback produced weak or unverifiable output, report that limitation; do not treat successful completion as quality approval.

## Fallback semantics

Fallback chains are error recovery for provider failures, rate limits and exhausted quotas. They do not evaluate answer quality and do not automatically escalate reasoning. A model can return a poor answer without triggering fallback. Route high-risk work to the appropriate role explicitly and require evidence-based review.

The configured chains prefer another provider quickly after rate limits. If all configured providers are unavailable, stop and report BLOCKED instead of silently dropping quality requirements.

## Local verification

Run:

```bash
omp models --kind chat
omp config list
```

Then start OMP and verify:
- no unknown-model/config warnings;
- `/work-spec` resolves to `@doc_tier`;
- `/work-build` implementation resolves to `@execution_tier`;
- Code Reviewer and QA resolve to their separate roles;
- Security Engineer resolves to `@security_tier`;
- a simulated/unavailable primary walks only the configured fallback chain.

Never paste API keys, OAuth tokens or credential files into diagnostics.

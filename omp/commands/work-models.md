---
description: Inspect configured model routing and available chat models without changing settings.
---

# /work-models

Read-only diagnostic for the local OMP model setup.

1. Run `omp models --kind chat` and inspect the exact provider/model selectors available in this installation.
2. Run `omp config list` and inspect only `modelRoles`, `task.agentModelOverrides`, `retry` and thinking-level settings.
3. Compare the active config with `omp/MODEL-ROUTING.md`. Report unknown selectors, missing credentials/availability only when the CLI exposes that fact, and agent names that do not exist.
4. Summarize the effective route for default, doc, execution, review, QA and security workloads, including fallback order.
5. Recommend the smallest config correction if a selector is invalid. Do not edit files, print secrets, test provider credentials destructively, or claim that fallback works unless it was actually exercised.

---
description: Translate approved human planning documents into OpenSpec and agent-ready specifications.
---

## Rule loading

- Read the installed shared `RULES.md` and `rules/core.md` before acting. Also read `rules/planning.md` and `rules/gates.md` for approval, review and freshness requirements; do not load unrelated stage rules.
## Load and gate

- Read project rules and re-enumerate/hash the complete human planning bundle.
- Require independent human-document review PASS and explicit human planning approval bound to the exact current manifest. Stop if inputs changed, approval is stale, or a material question is unresolved.
- Only now inspect installed OpenSpec help, config, schema and artifact instructions. Do not guess CLI commands or schema conventions.

## Prepare agent specifications

- Read the approved `interview.md`, `prd.md` when applicable, `design.md` when applicable, and `task-breakdown.md` in full.
- Use product-manager and tech-lead to translate approved intent into the installed OpenSpec schema's `proposal.md`, delta `specs/**/spec.md`, and any required design artifacts. These are derived execution specifications, not replacements for human documents.
- Preserve approved REQ IDs, acceptance criteria, scope, non-goals, assumptions and decisions. Link every agent requirement to its human source. Do not silently add scope, remove criteria or change technical decisions.
- If the schema requires details not settled in human documents, stop and return to planning; do not invent material behavior.
- Validate using the installed OpenSpec command discovered from actual help. Record invocation, exit status and full failure evidence. Do not create agent implementation tasks in this stage.
- Map each human REQ to its OpenSpec spec/requirement and identify any intentionally N/A mappings with reasons. Check for lost, added or contradicted requirements.

## Review and checkpoint

- Dispatch independent security-engineer and spec reviewer runs against the current prepared bundle and human-source manifest.
- Repair findings once within approved intent; any material change to human intent returns to planning and requires renewed human document approval. Do not launch parallel agents for redundant opinions.
- On PASS, show human-source documents, derived OpenSpec artifacts, REQ mapping, validation evidence, review verdicts and manifest.
- Require explicit human approval of the derived specification bundle before continuing to `/work-qa $1`. This does not replace human planning approval.

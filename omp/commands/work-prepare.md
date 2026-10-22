---
description: Translate approved human planning documents into OpenSpec and agent-ready specifications.
---

## Rule loading

- Read installed shared `RULES.md` and apply its activation check there. Read `rules/core.md`, `rules/planning.md` and `rules/gates.md`; do not load unrelated stage rules. Resolve paths under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`; stop if required policy is unreadable.

## Load and gate

- Change slug: $1. Recompute the human-planning manifest and require fresh `human-planning` approval bound to the exact current inputs. Stop if inputs changed, the decision is stale or a material question is unresolved.
- Only now inspect installed OpenSpec help, config, schema and artifact instructions; never guess CLI commands or conventions.

## Prepare derived specifications

- Read the approved human bundle in full and translate it with `tech-lead` as the single primary author into the installed schema's `proposal.md`, delta `specs/**/spec.md` and any required design artifact.
- Preserve approved REQ IDs, acceptance criteria, scope, non-goals, assumptions and decisions; link every requirement to its human source. Do not add scope, drop criteria or change technical decisions.
- Consult `product-manager` only for an unresolved product-requirement interpretation; stop for the operator rather than inventing intent. A material decision missing from approved human intent reopens planning.
- Validate with the installed OpenSpec command discovered from real help and record the invocation, exit status and failure evidence.
- Do not create schema `tasks.md` or `test-plan.md` here; `/work-qa` and `/work-plan` complete the same execution bundle.

## Handoff

- Continue to `/work-qa $1`. The derived specs join the execution bundle; there is no separate specification bundle approval.
- Report derived artifact paths, REQ-to-spec mapping including intentional N/A cases, and validation evidence. Note any human bundle that must be reopened.

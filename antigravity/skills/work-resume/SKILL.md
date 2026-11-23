---
name: work-resume
description: Recover the earliest incomplete step of an interrupted engineering workflow without assuming approvals or quality evidence remain valid.
---

# /work-resume

Read-only recovery first. Inspect OpenSpec changes, task checkboxes, reports, Git status, and current fingerprints. Identify the earliest incomplete stage. Never infer Gate 1 or Gate 2 approval from artifacts, previous conversations, or checked tasks. Never reuse quality evidence if target/spec fingerprint differs. Whenever user input, slug selection, or gate reconfirmation is required, use the built-in `ask_question` tool in the current conversation and stop. Report exact next action and blockers; do not silently start implementation.

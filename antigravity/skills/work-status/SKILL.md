---
name: work-status
description: Read-only status of OpenSpec changes, task progress, approvals, review evidence, fingerprints, and blockers.
---

# /work-status

Read-only. Inspect Git status and OpenSpec changes. Identify active change only when unambiguous; otherwise list candidates and use the built-in `ask_question` tool to ask the user which change to inspect. Report slug, Gate 1/Gate 2 approval state (never infer approval from files), task completion, current source/diff fingerprint, review/QA/security evidence status, stale evidence, blockers, and earliest next action. Do not edit files, start implementation, or claim a gate is approved from persisted artifacts. Approval is valid only when explicitly given in the current conversation.

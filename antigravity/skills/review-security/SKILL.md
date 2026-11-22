---
name: review-security
description: Fast read-only static security review of a diff, path, glob, or OpenSpec change with evidence-backed findings.
---

# /review-security [target] [output-dir] [context]

Read-only source inspection. Default target is current branch diff (PR base if unambiguous, otherwise repository default). Include committed branch changes plus tracked and untracked worktree changes. Ask if base/target is ambiguous. Write only to output-dir (default `.agy/reviews/<timestamp>-security/`); never edit reviewed files.

Inspect trust boundaries, authentication/session, authorization and tenant/object scoping, input validation, SQL/NoSQL/command/template/deserialization injection, XSS/output encoding, secrets/crypto, SSRF, uploads/path traversal, rate limiting, error leakage, dependencies/supply chain, and LLM/tool authorization. Cite exact file:line and explain concrete exploitability/impact, smallest fix and verification. Use IDs SEC-001 etc and severity P0-P3. Status PASS / FAIL / BLOCKED. PASS means no confirmed P0/P1 in stated scope, not proof of completeness. If scope or decisive facts unavailable, BLOCKED. Do not execute target code, live probes, or production endpoints.

---
name: review-patterns
description: Read-only architecture and maintainability review for SOLID, KISS, YAGNI, boundaries, coupling, and change risk.
---

# /review-patterns [target] [output-dir] [context]

Read-only. Resolve diff/path/glob/OpenSpec target and fingerprint it; ask if ambiguous. Write only under `.agy/reviews/<timestamp>-patterns/` or explicit output directory. Inspect module boundaries, dependency direction, cohesion, coupling, duplication, abstractions, dead code, error handling, ownership, and likely change amplification. Apply SOLID only where variation is real; prefer KISS and YAGNI. Each finding PAT-001 etc must include exact file:line, concrete maintenance consequence, smallest practical change, and verification. Distinguish issue from preference. PASS / FAIL / BLOCKED; never change reviewed files.

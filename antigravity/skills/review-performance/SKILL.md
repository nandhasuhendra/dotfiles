---
name: review-performance
description: Read-only performance and scalability review covering queries, complexity, memory, I/O, caching, and concurrency.
---

# /review-performance [target] [output-dir] [context]

Read-only. Resolve and fingerprint diff/path/glob/OpenSpec target; ask if ambiguous. Write only under `.agy/reviews/<timestamp>-performance/` or explicit output directory. Inspect N+1 queries, missing indexes, unbounded scans, pagination, algorithmic complexity, allocations/memory, I/O, caching correctness, concurrency, contention, timeouts, retries and backpressure. Do not claim measured performance without benchmarks/profiling. Each finding PERF-001 etc includes exact file:line, workload assumptions, expected failure/scaling mode, smallest fix, and verification/benchmark plan. PASS / FAIL / BLOCKED. Never modify reviewed files.

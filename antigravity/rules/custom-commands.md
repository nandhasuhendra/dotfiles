# Custom Slash Commands & Subagent Routing Rules

When the user enters any of the following slash commands or requests in their prompt, you must strictly follow the routing and operational protocol below. Always invoke the corresponding custom agent using `invoke_subagent` (or load its role context) rather than attempting to execute generic ad-hoc answers.

## Command Mappings

### 1. `/planning [feature or problem statement]`
- **Target Subagent:** `document-orchestrator`
- **Action:** Call `invoke_subagent` with `name: "document-orchestrator"`.
- **Workflow:**
  1. Product discovery & PRD drafting (via Product Manager using `${XDG_CONFIG_HOME:-$HOME/.config}/opencode/templates/PRD.md`).
  2. Architecture & technical document drafting (via Team Leader with 4 Mermaid diagrams using `${XDG_CONFIG_HOME:-$HOME/.config}/opencode/templates/TECH-DOC.md`).
  3. Technical & contract review (via Senior Architect).
  4. Security & threat analysis (via Senior Security Engineer).
  5. Final reconciliation and verb-first task breakdown (via Team Leader).
- **Boundary:** Do NOT write or modify application source code during `/planning`.

### 2. `/plan-review [path/to/plan or prompt]`
- **Target Subagent:** `team-leader`
- **Action:** Call `invoke_subagent` with `name: "team-leader"`.
- **Workflow:**
  1. Audit document completeness against `templates/TECH-DOC.md`.
  2. Verify 4 Mermaid diagrams (High-Level Architecture, Flowchart, Sequence, ERD).
  3. Validate 100% traceability from `PRD-` requirement IDs to engineering tasks and verification criteria.
  4. Audit task breakdown (verb-first titles, assigned roles, acyclic dependencies, realistic sizing).
  5. Deliver Executive Verdict: `APPROVED`, `APPROVED WITH CONDITIONS`, or `NEEDS REVISION`.

### 3. `/prd-review [path/to/prd or prompt]`
- **Target Subagent:** `product-manager`
- **Action:** Call `invoke_subagent` with `name: "product-manager"`.
- **Workflow:**
  1. Audit against `templates/PRD.md`.
  2. Validate problem statement, customer personas, and business value.
  3. Enforce scope discipline: first-release MVP strictly separated from future opportunities and explicit non-goals.
  4. Audit user journeys covering unauthenticated states, permissions, error recovery, and data boundaries.
  5. Verify all requirements have stable IDs (`PRD-XXX`) and testable acceptance criteria.
  6. Deliver Executive Verdict: `APPROVED`, `APPROVED WITH MINOR EDITS`, or `NEEDS MAJOR REVISION`.

### 4. `/technical-review [path/to/doc or diff]`
- **Target Subagent:** `senior-architect-engineer`
- **Action:** Call `invoke_subagent` with `name: "senior-architect-engineer"`.
- **Workflow:**
  1. Audit architecture against `templates/TECH-DOC.md`.
  2. Evaluate component boundaries, modularity, coupling, and adherence to existing repo patterns.
  3. Audit API, event, and database schemas (ERD, typing, idempotency, error structures).
  4. Evaluate NFRs (scalability, latency, mandatory client timeouts, backoff, circuit breaking).
  5. Verify Expand-and-Contract database migrations and zero-downtime rollback plans.
  6. Deliver Architecture Decision Record (ADR) and Executive Verdict: `APPROVED`, `APPROVED WITH REVISIONS`, or `REJECTED`.

### 5. `/git-push [remote] [branch]`
- **Target Subagent:** `senior-devops-engineer`
- **Action:** Call `invoke_subagent` with `name: "senior-devops-engineer"`.
- **Workflow:**
  1. Inspect `git status`, active branch, and upstream tracking (`@{u}`).
  2. Audit outgoing commits: scan diff lines for leaked secrets (API keys, tokens, `.env`, credentials) and build artifacts. Abort immediately if any secret is found.
  3. Verify local linting and test checks pass.
  4. Gate check: Confirm with user before pushing to protected branches (`main`, `master`, `production`). Never force push without explicit request.
  5. Execute `git push` safely and report remote commit hash.

### 6. `/git-sync [remote] [branch]`
- **Target Subagent:** `senior-devops-engineer`
- **Action:** Call `invoke_subagent` with `name: "senior-devops-engineer"`.
- **Workflow:**
  1. Working tree check: Alert user and stop if uncommitted changes exist (offer safe stash).
  2. Fetch remote references (`git fetch --prune`) and compute divergence (ahead/behind counts).
  3. Pre-assess conflict risk by comparing changed files.
  4. Execute synchronization (rebase or merge according to repo conventions). Never execute destructive resets.
  5. Restore stash if previously stashed and verify clean branch state.

### 7. `/security-review [target file, PR, or scope]`
- **Target Subagent:** `senior-security-engineer`
- **Action:** Call `invoke_subagent` with `name: "senior-security-engineer"`.
- **Workflow:**
  1. Map trust boundaries, unauthenticated entry points, and sensitive assets.
  2. Red Team attack modeling: Auth bypass, BOLA/IDOR, SQL/command injection, SSRF, XSS, CSRF, and secret leaks.
  3. Blue Team defense: Concrete remediation patches, secure defaults, and regression test cases.
  4. Deliver prioritized findings (CRITICAL, HIGH, MEDIUM, LOW) with exact file/line references, PoC attack vectors, and verified fixes.

### 8. `/qa-testing [test command or target scope]`
- **Target Subagent:** `senior-qa-engineer`
- **Action:** Call `invoke_subagent` with `name: "senior-qa-engineer"`.
- **Workflow:**
  1. Discover project test runners and configuration (`package.json`, `pytest`, `cargo`, `go test`).
  2. Execute tests relevant to changed files or specified arguments in isolated test environment.
  3. Triage failures: Distinguish true product bugs from stale tests or environment flakes.
  4. Reproduce confirmed bugs with minimal steps.
  5. Deliver structured QA report with pass/fail counts, defect logs, untested areas, and GO/NO-GO verdict.

### 9. `/qa-test-scenario [feature, PRD, or requirement]`
- **Target Subagent:** `senior-qa-engineer`
- **Action:** Call `invoke_subagent` with `name: "senior-qa-engineer"`.
- **Workflow:**
  1. Map requirements to stable `PRD-` IDs for 100% bidirectional traceability.
  2. Design scenarios across 4 quadrants: Happy Path, Negative/Validation, Boundary/Edge Cases, and Concurrency/Resilience.
  3. Enforce schema for each scenario: ID, Traced PRD ID, Title, Category, Test Level, Priority (P0 Blocker, P1 High, P2 Medium), Preconditions, Steps, and Expected Observable Outcome.
  4. Provide automation implementation guidance (unit vs integration vs E2E) and non-negotiable release gate criteria.

### 10. `/implementation [feature, task, or bugfix]` (Alias: `/implement`)
- **Target Subagent:** `team-leader` (Orchestrator coordinating `senior-architect-engineer`, `senior-backend-engineer`, and `senior-frontend-engineer`)
- **Action:** Call `invoke_subagent` with `name: "team-leader"`.
- **Workflow & Agent Coordination:**
  1. `team-leader`: Intake requirement or task IDs (`TASK-XXX`, `PRD-XXX`), analyze scope, map dependencies, and set execution order.
  2. `senior-architect-engineer`: Validate architectural coherence, verify API and database contracts, ensure zero-downtime safety and backward compatibility.
  3. `senior-backend-engineer`: Implement server-side logic, database migrations, API routes, and backend unit/integration tests with boundary validation.
  4. `senior-frontend-engineer`: Implement UI components, user interactions, responsive layouts, accessibility (a11y), client API integration, and frontend tests.
  5. `team-leader`: Coordinate integration, execute full project test/lint/typecheck verification, and deliver the final Implementation Completion Report.

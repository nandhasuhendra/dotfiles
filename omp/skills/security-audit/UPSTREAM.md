# Security audit skill attribution

This directory includes the `security-audit` skill from [cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill), specifically `skills/security-audit/` plus its `LICENSE`.

- Upstream source: https://github.com/cloudflare/security-audit-skill/tree/main/skills/security-audit
- Upstream license: MIT; see [LICENSE](LICENSE) or https://github.com/cloudflare/security-audit-skill/blob/main/LICENSE
- Local copy is vendored so the OMP and OpenCode workflows can load the same audited prompt set reproducibly. Do not edit the vendored files; adapt harness behavior in `omp/agents/security-audit-*.md`, `omp/commands/security-audit.md` and the OpenCode equivalents.
- Upstream tags the skill `security-audit`; keep that name so the frontmatter trigger and the workflow links stay valid.

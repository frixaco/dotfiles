---
name: brooks-lint
description: "Codebase quality review, architecture audit, tech-debt triage, test-suite diagnosis, health scoring, Grug Brain simplicity lens, and safe cleanup sweeps. Use for PR reviews, architecture health, refactoring priorities, brittle tests, hard-to-change code, or requested auto-fix sweeps."
---

# Brooks Lint

Use this skill for code-quality work that needs a structured engineering review instead of a normal implementation pass.

## Pick The Mode

- PR/code review: read `references/review/pr-review-guide.md`.
- Architecture or onboarding audit: read `references/audit/architecture-guide.md`; for newcomer explanations also read `references/audit/onboarding-guide.md`.
- Tech-debt roadmap: read `references/debt/debt-guide.md`.
- Test-quality review: read `references/test/test-guide.md`.
- Whole-codebase health score: read `references/health/health-guide.md`.
- Sweep with fixes: read `references/sweep/sweep-guide.md`, then implement only low-risk changes directly.
- Architecture improvement/refactoring candidates: read the relevant files in `references/improve/`.
- Grug Brain simplicity, product scoping, API/schema design, premature abstraction, or complexity pushback: read `references/grug-brain.md`.

## Shared References

Use shared guides only when a selected mode calls for them:

- `references/shared/common.md`
- `references/shared/decay-risks.md`
- `references/shared/test-decay-risks.md`
- `references/shared/remedy-guide.md`
- `references/shared/custom-risks-guide.md`
- `references/shared/source-coverage.md`

## Rules

- Lead reviews with findings ordered by severity and grounded in file/line references.
- Prefer concrete symptoms, source causes, consequences, and remedies.
- Do not broaden into unrelated refactors unless the user asked for a sweep.
- For fix sweeps, preserve user changes and ask before risky or behavior-changing edits.

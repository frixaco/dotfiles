# AGENTS.md

## Response Style

- Concise; telegraph style; drop grammar for brevity
- Plans: bullet-only, no prose

## Task Rules

- One logical change per task; prefer many small tasks
- State assumptions before writing code
- Fix root causes, not symptoms
- Keep files under ~500 LOC; split when needed

## Code Rules

- Match existing style, patterns, libraries in surrounding code
- Error paths get equal thought to happy paths
- Before writing: identify inputs, edge cases, failure modes
- New dependencies: check recency and adoption first

### Do Not

- Guess at correctness — verify it
- Handle happy path only
- Import unneeded complexity
- Solve problems not asked for

## Testing

Pick strategy by scenario:

| Scenario                     | Strategy                                            |
| ---------------------------- | --------------------------------------------------- |
| Complex/large output         | Snapshot / golden file                              |
| Logic tangled with I/O       | Functional core + imperative shell                  |
| External system interaction  | Black-box: verify your input, snapshot their output |
| OS/runtime-level integration | Full environment (containers, VMs)                  |

General:

- Verification-first: define end state, then build toward it
- Bugs: add regression test when it fits

## Pre-Handoff Checklist

- [ ] Lint passes
- [ ] Typecheck passes
- [ ] Tests pass
- [ ] No unintended changes to unrelated files

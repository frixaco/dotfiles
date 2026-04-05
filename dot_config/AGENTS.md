# AGENTS.md

## Response Style

- Write like a clear senior teammate: brief, direct, and natural; optimize for fast understanding, not minimal word count
- Present plans in the clearest format for quick execution - usually bullets, sometimes short sections or brief prose

## Task Rules

- One logical change per task; prefer many small tasks
- State assumptions before writing code
- Fix root causes, not symptoms

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
- Forget to clean temporary files (e.g. in /tmp)

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

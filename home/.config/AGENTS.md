# Global agent instructions

## Communication

- Use ASD-STE100 Simplified Technical English in all user-facing messages. Use approved, simple words and short sentences when possible. Keep necessary technical terms when no accurate simpler term exists, and define them on first use.
- Lead with the answer or next action. Skip pleasantries, plan announcements, filler, and closing recaps.
- Write like a clear senior teammate for a smart reader new to the system: use plain English, direct sentences, one idea per sentence, and define necessary jargon.
- Explain behavior as actor → action → result. Use short examples for workflows, state changes, money movement, or concurrency when prose is hard to follow. Include implementation names only when they help the reader act or verify.

For multi-step work:

- Number bounded steps. On every turn, state what is done and what comes next.
- Keep lists to five items; split longer lists into ranked groups.
- When time matters, use concrete estimates. If work remains, end with one action that takes under two minutes to start; if complete, stop.

Keep work focused:

- Finish the current issue before raising a separate one.
- Report outcomes concretely: success = what works + how to verify it; failure = failure → cause → fix.
- Ask one short question when the request is genuinely ambiguous.
- After three failed debugging turns, stop editing, name the assumption most likely to be wrong, and ask one diagnostic question.
- Before a destructive action, confirm the exact target and effect.

## Code

- State assumptions before coding. Make one logical change, fix the root cause, and do not add fallbacks, parallel versions, or MVP-style branches. Make a supporting refactor only when it leaves the requested change simpler; do not expand into unrelated cleanup.
- After understanding the task and tracing the affected flow, stop at the first solution that works: skip speculative work → reuse existing code → use the standard library → use a native platform feature → use an installed dependency → keep it to one line → only then write the minimum new code.
- Prefer the fewest files and keep small local logic at its call site, especially one-liners used once or twice. A helper or file must protect a runtime boundary, remove non-trivial duplication, or give a stable domain concept a necessary home. For bloat, refactoring, module ownership, helpers, or structural simplification, invoke `debloat-code` before editing.
- Organize modules top-down: overview comment when the purpose or invariant is not obvious → main export → exported types and domain vocabulary → core logic → constants and configuration → internal types → private helpers and utilities. Prefer proximity when it helps; do not split honest workflows into tiny helpers.
- Comment whenever a reader must pause or infer intent. Explain the reason, invariant, constraint, or tradeoff—not the syntax—in plain English for a reader unfamiliar with the code, and define necessary domain terms.

## Testing

- Define the observable end state before implementation. Make core decisions and transformations testable through explicit inputs and outputs; keep network, database, filesystem, clock, and randomness at the boundaries.
- Leave one smallest runnable check for non-trivial logic. Test public behavior, not implementation details; do not add frameworks, fixtures, per-function suites, or abstractions only for mocking unless the task or risk boundary requires them.
- For a bug, make that check a regression test when practical. Expand beyond one check only when repository instructions require it or one check cannot establish the requested behavior safely.

Choose the test strategy by boundary:

| Situation                   | Strategy                                              |
| --------------------------- | ----------------------------------------------------- |
| Complex or large output     | Snapshot or golden file                               |
| Logic tangled with I/O      | Functional core with an imperative shell              |
| External system interaction | Black box: verify our input and snapshot their output |
| OS or runtime integration   | Full environment such as a container or VM            |

## Tools

- Prefer `fff` tools over `grep` or `ripgrep`.
- When using `chrome-devtools` MCP, prefer running Helium browser, otherwise launch it with CDP flag and do not create new profile.

# Debloat review (list-only)

Trigger: the user says "review for over-engineering", "what can we delete", "is this over-engineered", or "simplify review" (review the current diff); or "audit this codebase", "audit for over-engineering", "what can I delete from this repo", or "find bloat" (scan the whole tree).

Hunt unnecessary complexity only. List findings; apply nothing. One line per finding: location, what to cut, what replaces it. The diff's best outcome is getting shorter. For a repo-wide audit, rank findings biggest cut first.

Tags:

- `delete:` dead code, unused flexibility, speculative feature. Replacement: nothing.
- `stdlib:` hand-rolled thing the standard library ships. Name the function.
- `native:` dependency or code doing what the platform already does. Name the feature.
- `yagni:` abstraction with one implementation, config nobody sets, layer with one caller.
- `shrink:` same logic, fewer lines. Show the shorter form.

Format: `L<line>: <tag> <what>. <replacement>.` (multi-file: `<file>:L<line>: ...`; audit: `<tag> <what to cut>. <replacement>. [path]`).

Examples:

- `L12-38: stdlib: 27-line validator class. "@" in email, 1 line, real validation is the confirmation mail.`
- `L4: native: moment.js imported for one format call. Intl.DateTimeFormat, 0 deps.`
- `repo.py:L88: yagni: AbstractRepository with one implementation. Inline it until a second one exists.`
- `L52-71: delete: retry wrapper around an idempotent local call. Nothing replaces it.`
- `L30-44: shrink: manual loop builds dict. dict(zip(keys, values)), 1 line.`

End with `net: -<N> lines possible.` (audit: `net: -<N> lines, -<M> deps possible.`). Nothing to cut: `Lean already. Ship.`

Over-engineering and complexity only: correctness bugs, security holes, and performance go to a normal review, not this one. A single smoke test or `assert`-based self-check is the minimum, not bloat — never flag it for deletion. Lists only; the Debloat pass above applies the fixes.

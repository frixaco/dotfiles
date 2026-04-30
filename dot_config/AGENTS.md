# GLOBAL AGENTS.md

## Response Style

- Write like a clear senior teammate: brief, direct, and natural; optimize for fast understanding, not minimal word count or essays
- Present plans in the clearest format for quick execution - usually bullets, sometimes short sections or brief prose

## Task Rules

- One logical change per task; prefer many small tasks
- State assumptions before writing code
- Fix root causes, not symptoms
- No fallbacks, no MVP/v1/v2 type of code. Only single final version.
- Do not be afraid to do simple refactors if the feature/fix you are implementing will be smaller/cleaner or just won't exist

## Code Rules

- Match existing style, patterns, libraries in surrounding code
- Error paths get equal thought to happy paths
- Before writing: identify inputs, edge cases, failure modes
- New dependencies: check recency and adoption first
- Add comments only when necessary e.g. to explain "black box"-like code

## File structure

Organize files for **top-down readability**. A new reader should understand the module's purpose, public API, domain language, and implementation details in that order.

Use this general order:

1. **Module overview comment, if useful**
   - Add a short comment only when the file's purpose is not obvious from its name and main export.
   - Explain the module's intent, invariants, or important context.
   - Do not duplicate the list of imports, exports, parameters, or return values.

2. **Main export**
   - Put the primary component, function, class, service, hook, handler, etc. near the top.
   - Readers should see the module's main API before implementation details.

3. **Exported types and domain vocabulary**
   - Define exported types, interfaces, schemas, enums, constants, and domain names used by the main export.
   - These should explain the language of the module: states, variants, events, commands, payloads, operations, etc.

4. **Core implementation logic**
   - Place the main logic next: transformation, validation, orchestration, rendering, data fetching, state transitions, business rules, etc.
   - Prefer small, named functions over large inline blocks when it improves readability.

5. **Constants and configuration**
   - Group defaults, limits, keys, selectors, route names, query names, timing values, and other repeated values in a predictable place.
   - Avoid scattering magic values throughout the file.

6. **Supporting internal types**
   - Add non-exported types that exist only to support the implementation: intermediate shapes, internal options, helper result types, local state shapes, etc.

7. **Private helpers**
   - Put local helper functions near the bottom.
   - Helpers should be small, focused, and named after what they do.
   - If a helper becomes reusable across files, move it to a shared module.

8. **Tiny utilities**
   - Put adapters, singletons, caches, formatters, mappers, and tiny low-level utilities last unless they are central to understanding the file.

Do not follow this order mechanically if it makes the file harder to read. Prefer proximity when a type, constant, or helper is only meaningful next to the code that uses it.

### Do Not

- Guess at correctness — verify it
- Handle happy path only
- Import unneeded complexity
- Solve problems not asked for
- Forget to clean temporary files (e.g. in /tmp)
- Over-engineer
- Prematurely abstract
- Write million tiny helpers everywhere

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

## Tool and MCP use

- Use `fff` tools when available over `grep`/`ripgrep`

## Pre-Handoff Checklist

- [ ] Lint passes
- [ ] Typecheck passes
- [ ] Tests pass
- [ ] No unintended changes to unrelated files

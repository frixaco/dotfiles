# Global Agent Guidelines

This file provides global guidance for AI coding agents across all projects.

---

## Output Style

- Telegraph; noun-phrases ok; drop grammar; min tokens
- Plans extremely concise. Sacrifice grammar for brevity.

---

## Planning & Execution Loop

**Plan Mode Rules**

- End each plan with unresolved questions, if any.

**Task Sizing**

- One logical change per task
- Prefer many small tasks over few large ones
- Quality over speed. Small steps compound into big progress.

---

## Code Generation Principles

Code is frozen thought. The bugs live where the thinking stopped too soon.

This codebase will outlive you. Every shortcut becomes someone else's burden. Every hack compounds into technical debt. The patterns you establish will be copied. The corners you cut will be cut again. Fight entropy. Leave the codebase better than you found it. You are shaping the future of this project.

The question is not "Does this work?" but "Under what conditions does this work?"

### Notice the Completion Reflex

- The urge to produce something that runs
- The pattern-match to similar problems you've seen
- The assumption that compiling is correctness
- The satisfaction of "it works" before "it works in all cases"

### Before Writing

- What are you assuming about the input?
- What are you assuming about the environment?
- What would break this?
- What would a malicious caller do?
- What would a tired maintainer misunderstand?

### While Writing

- Let the code be smaller than your first instinct
- Let edge cases surface before you handle them
- Error paths deserve as much thought as happy paths
- Comments explain _why_, not _what_

### Do Not

- Write code before stating assumptions
- Claim correctness you haven't verified
- Handle the happy path and gesture at the rest
- Import complexity you don't need
- Solve problems you weren't asked to solve
- Produce code you wouldn't want to debug at 3am
- Band-aid over symptoms; fix root cause

### When Stuck

- Read more code; if still unsure, ask with short options
- Conflicts: call out; pick safer path

### Code Hygiene

- Keep files <~500 LOC; split/refactor as needed
- New deps: quick health check (recent releases, adoption)
- Before handoff: run full gate (lint/typecheck/tests/docs)

> The tests you didn't write are the bugs you'll ship.
> The assumptions you didn't state are the docs you'll need.
> The edge cases you didn't name are the incidents you'll debug.

---

## Testing Strategies & Patterns

When writing or refactoring tests, apply these patterns based on the scenario:

### Two Pillars of Testing

1. **Testing Strategy**: _How_ to test something (techniques)
2. **Testability**: Making code capable of being tested (structure/design)

> If software isn't made testable, "this can't be tested" is often true. Pair strategy with testability.

**Verification-First Mindset**

- Steps describe HOW TO TEST, not how to build
- Define the end state first, then decide how to get there
- Bugs: add regression test when it fits

### Strategy 1: Snapshot Testing (Golden Files)

**Use when**: Output is complex, large, or hard to assert programmatically (images, graphs, complex text).

- Avoid writing hundreds of manual checks
- Provides full context on failures (spot patterns in diffs)

### Strategy 2: Isolating Side Effects — Functional Core, Imperative Shell

**Use when**: Logic is tangled with I/O (database, network, user input, OS state). The #1 technique for making "untestable" code testable.

1. **Imperative Shell**: Reads all state first (config, input, time). No logic.
2. **Functional Core**: Takes state as arguments, performs logic, returns result. Pure/deterministic.

### Strategy 3: Black-Box / External System Testing

**Use when**: Testing code that interacts with external systems (hardware, APIs, third-party services).

- Treat external system as pure function (Data In → Data Out)
- Test your side: verify you send correct input
- Test their side: use minimal integration tests with real system, compare output via snapshots

### Strategy 4: Full Environment Testing (Nuclear Option)

**Use when**: Deep integrations where mocking is impossible (OS-level behavior, specific runtime environments).

- Use reproducible environments (containers, VMs, NixOS)
- Script environment interaction to assert end-to-end results
- Reserve for cases where isolation strategies fail

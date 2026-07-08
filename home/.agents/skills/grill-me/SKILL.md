---
name: grill-me
description: 'Stress-test a plan, design, domain model, or terminology through one-question-at-a-time grilling. Use when the user says "grill me", wants hard questions, wants a design challenged, or wants CONTEXT.md/ADR updates while decisions crystallize.'
---

# Grill Me

Interview the user relentlessly about every aspect of the plan until reaching shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one by one.

## Rules

- Ask one question at a time and wait for the answer before continuing.
- For each question, include your recommended answer or the tradeoff you see.
- If a question can be answered by exploring the codebase, inspect the codebase instead of asking.
- Challenge fuzzy or overloaded terms immediately.

## Documentation Mode

When the user wants the plan challenged against project language or asks to update docs:

- Look for `CONTEXT.md`, `CONTEXT-MAP.md`, and `docs/adr/`.
- If a resolved term belongs in domain language, update `CONTEXT.md` inline using `references/CONTEXT-FORMAT.md`.
- Offer an ADR only for decisions that are hard to reverse, surprising without context, and the result of a real tradeoff. Use `references/ADR-FORMAT.md`.
- Do not couple `CONTEXT.md` to implementation details; keep it meaningful to domain experts.

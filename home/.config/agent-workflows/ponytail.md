# Ponytail debt ledger

Trigger: "ponytail debt", "what did ponytail defer", "list the shortcuts", "ponytail ledger", or "what did we mark to do later".

Every deliberate shortcut is marked with a `ponytail:` comment naming its ceiling and upgrade path. Harvest them into one ledger so a deferral cannot quietly become permanent.

Scan the repo for comment markers, skipping `node_modules`, `.git`, and build output: `grep -rnE '(#|//) ?ponytail:' .` (add other comment prefixes if the stack uses them). Each hit is one ledger row.

Output, one row per marker, grouped by file: `<file>:<line>, <what was simplified>. ceiling: <the limit named>. upgrade: <the trigger to revisit>.` The convention is `ponytail: <ceiling>, <upgrade path>` — pull both straight from the comment. Want an owner per row too? Add `git blame -L<line>,<line>`.

Flag rot risk: a `ponytail:` comment that names no upgrade path or trigger gets a `no-trigger` tag — those silently rot.

End with `<N> markers, <M> with no trigger.` Nothing found: `No ponytail: debt. Clean ledger.`

Reads and reports only, changes nothing. To persist it, ask first, then write the ledger to a file (e.g. `PONYTAIL-DEBT.md`).

# Ponytail gain scoreboard

Trigger: "ponytail gain", "what does ponytail save", "show ponytail impact", or "ponytail scoreboard".

Display the scoreboard below. One-shot: do not change mode or persist anything. The figures are the published benchmark medians (5 everyday tasks: email validator, debounce, CSV sum, countdown timer, rate limiter; three models: Haiku, Sonnet, Opus) — measured, not computed from the current repo.

Render plain ASCII bars; the bar shows the measured range and the label carries the exact figure:

```txt
  ponytail gain                     benchmark median · 5 tasks · 3 models

  Lines of code   no-skill  ████████████████████  100%
                  ponytail  ██▌·················    6–20%   ▼ 80–94%
  Cost            no-skill  ████████████████████  100%
                  ponytail  █████▌··············   23–53%  ▼ 47–77%
  Speed           ponytail  ▸ 3–6× faster

  This repo:  "ponytail debt"        (shortcuts you deferred)
              "audit this codebase"  (what's still cuttable)
```

Honesty boundary: benchmark medians, not this repo. Never print a per-repo savings number — the unbuilt version was never written, so no real baseline exists. The only real per-repo figures come from the debt ledger above.

# Ponytail help card

Trigger: "ponytail help", "what ponytail commands", or "how do I use ponytail".

Display this card. One-shot.

These are plain-language requests, not installed commands, plugins, skills, or modes. The shared AGENTS.md holds the default code rules and the `ponytail:` comment convention. It points to plain Markdown files for each optional workflow.

On-command trigger words: "grill me" — design-tree interview. "debloat" — Debloat pass, applies fixes. "what can we delete" — list-only review of the diff. "audit this codebase" — repo-wide ranked list. "ponytail debt" — debt ledger. "ponytail gain" — scoreboard. "ponytail help" — this card.

Full docs: https://github.com/DietrichGebert/ponytail

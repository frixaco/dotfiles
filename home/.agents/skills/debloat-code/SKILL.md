---
name: debloat-code
description: Codebase de-bloating and refactor triage. Use when the user complains about "bloat", "too many helpers", "junk drawer utils", "over-abstraction", "code quality", "messy components", "should this live in lib", or asks to simplify/refactor modules, layout structure, JSX/markup nesting, Tailwind/class styling, wrappers, helpers, or conditionals while preserving behavior. Applies Ponytail's shortest-working-diff bias, then inspects usage graphs, runtime boundaries, and ownership to keep reductions safe; prefers measurable deletion over cosmetic churn and verifies behavior with the smallest meaningful check.
---

# Debloat Code

## Philosophy

Prefer the smallest correct codebase. Net removed lines, files, dependencies, and concepts are the primary outcomes; responsibility, ownership, and runtime boundaries prevent unsafe or misleading cuts.

Default to fewer files and inline local logic. Keep a small file or helper only when it protects a real runtime boundary, removes non-trivial duplication, or gives a stable domain concept a necessary home. A large file can be an honest workflow and should not be split merely to look clean.

Do not move code into `lib`, `utils`, `model`, `shared`, or `services` unless multiple real callers need it or the boundary is domain-level and stable. A named concept alone does not earn extraction; first ask whether the code is clearer as one local line.

## Ponytail Priority

Ponytail wins ties. Choose the fewest files, shortest implementation, smallest runnable check, and largest verified deletion unless evidence shows that choice would cross a runtime boundary, change requested public behavior, or remove trust-boundary validation, data-loss protection, security, accessibility, or an explicit requirement.

## Workflow

1. **Map actual usage first**
   - Search imports and call sites before judging a file.
   - Count who imports each export, but do not decide by count alone.
   - Identify whether exports are used across features, only within one feature, or not at all.

2. **Classify by ownership**
   - Route-owned: search validation, loader inputs, redirects, public URL shape.
   - Component-owned: render state, UI interaction state, DOM/browser effects.
   - Feature-owned: API client calls, query options, result normalization for one user workflow.
   - Domain-owned: stable business rules, persistence, external API adapters, billing rules.
   - Shared-owned: framework glue or utilities with broad, repeated use.

3. **Check runtime boundaries**
   - Keep client-only code away from server-only imports.
   - Keep server secrets, DB clients, SDK clients, and auth server config out of files imported by components.
   - Pure helpers may be shared; runtime clients usually should not be.

4. **Prefer evidence-backed moves**
   - Delete unused files only after confirming no imports or framework convention usage.
   - Collapse needless files and inline one-use helpers by default, including named helpers whose indirection costs more than the local code.
   - Extract only when it removes non-trivial duplication, protects a runtime boundary, or a stable domain concept is harder to understand inline.
   - Prefer fewer wrappers, direct JSX, and inline class names over opaque Tailwind/class-string aliases.
   - Report the net lines, files, and dependencies removed; do not count code merely moved between files as simplification.

5. **Verify behavior**
   - Preserve external behavior unless the user explicitly asks to simplify the product flow.
   - Run the smallest existing check that proves the changed public behavior.
   - If non-trivial logic has no check, leave one small runnable assertion or regression test; do not add a framework, fixtures, or a broad suite unless required.
   - Expand verification only when repository instructions require it or one check cannot cover the relevant risk boundary.
   - Note pre-existing failures separately from refactor fallout.

## Good Targets

- A `utils.ts` with unrelated parsing, formatting, API, and UI helpers.
- A `model.ts` that exports many one-use helpers and no stable domain model.
- A component that contains API clients, query keys, route search parsing, DOM effects, and JSX in one file.
- Duplicate parsing or normalization logic in client and server modules.
- A generically named file like `api-access.ts` that is really billing, auth, or provider-specific code.
- Unused framework helper files left behind after patterns changed.
- Tiny files and wrappers that export one locally used operation without protecting a boundary.

## Bad Moves

- Moving code to `lib` just to make a component smaller.
- Creating generic hooks like `useAppQuery` or `useApiMutation` that hide useful library APIs.
- Splitting a large honest workflow into many tiny files with vague names.
- Merging client and server code into one file because both mention the same product concept.
- Renaming everything without reducing ambiguity.
- Refactoring unrelated warnings or old code while doing a scoped de-bloat pass.

## Naming Heuristics

Use names that say what boundary the file owns:

- `search.ts`: route/search-param parsing and URL search helpers.
- `queries.ts`: TanStack Query keys and `queryOptions` factories.
- `api.ts`: feature-local browser calls to app API routes.
- `billing-access.ts`: server-side billing authorization and usage ingestion.
- `credits.ts`: pure credit math and shared parsing.

Avoid vague buckets:

- `model.ts` unless it contains actual domain models.
- `utils.ts` for feature-specific business behavior.
- `service.ts` when it is just a bag of functions.
- `helpers.ts` when ownership is knowable.

## Examples

### Example: Component With Too Much Workflow

User says: "This component has createJob, fetchJobStatus, a million helpers, and query imports. It works but feels bloated."

Approach:

1. Read the component and nearby files.
2. Identify responsibilities: UI, route search, API calls, query config, result shaping, export/download effects.
3. Delete unused helpers and inline one-use transformations, API wrappers, and query configuration when they remain readable.
4. Keep the workflow together when it serves one component and one runtime.
5. Extract a feature-local `api.ts`, `queries.ts`, or route helper only for repeated callers or a real browser/server boundary.
6. Leave the smallest component and file set that still makes the workflow understandable.

Do not move the workflow hook to `lib` or split it merely because it is long. If one feature owns the UI orchestration, keep it with that feature and prefer proximity.

### Example: Junk Drawer Model File

User says: "`model.ts` exports a billion things and only two are used elsewhere."

Approach:

1. Search all imports from `./model`.
2. For each export, ask where the concept naturally belongs.
3. Move API response types next to API functions.
4. Move query-only helpers into `queries.ts` as private functions.
5. Inline one-use workflow helpers into the workflow hook.
6. Delete `model.ts` if no actual model remains.

### Example: Suspicious Small Lib Files

User says: "`web/src/lib` has a bunch of tiny files. Is this bloat?"

Approach:

1. Build an import map for every lib file.
2. Mark runtime type: pure, client-only, server-only, external provider adapter, database/domain.
3. Delete unused files after confirming no imports or framework-owned loading convention.
4. Inline or combine locally used files that share one runtime and workflow.
5. Keep a tiny file only when it isolates a runtime dependency, e.g. `db.ts`, `auth-client.ts`, or `polar.ts`.
6. Rename only surviving boundaries whose current name hides their ownership.

## Runtime Boundary Checklist

Before merging files, ask:

- Would a React component import this file?
- Does the file import DB, server auth, SDK clients, environment secrets, or Node-only packages?
- Does the file import browser/client auth, DOM, clipboard, Blob, or React hooks?
- Can the shared code be made pure and imported by both sides?

Boundary exception when client and server import different parts:

```txt
credits.ts          # pure shared math/parsing
credits-store.ts    # client query key + client fetch
billing-access.ts   # server auth, credit checks, usage ingestion
```

Keep this split only when the imports actually cross those runtimes. If one workflow in one runtime owns all three, colocate or inline them instead.

## Query Abstraction Rule

For TanStack Query, keep a one-use `queryOptions` call at its call site. Use a named option factory only when multiple real callers share cache behavior; even then, prefer it over a broad custom query wrapper:

```ts
export const fetchJobQueries = {
  status: (jobId: string | null) =>
    queryOptions({
      queryKey: ["fetch-job", "status", jobId],
      queryFn: () => fetchJobStatus(requiredJobId),
    }),
};
```

Do not extract the example for one caller. Use custom hooks only when workflow orchestration owns UI transitions and side effects. Do not hide TanStack Query behind generic abstractions that make cache keys, enabled states, or invalidation harder to see.

## Final Response Pattern

When reporting a de-bloat pass:

- Name what moved and why.
- Name what was deleted.
- Mention behavior preservation.
- Mention the smallest check run.
- Separate pre-existing failures from new refactor failures.
- End with measurable impact: `net: -<N> lines, -<M> files, -<D> dependencies.`

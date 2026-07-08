---
name: debloat-code
description: Codebase de-bloating and refactor triage. Use when the user complains about "bloat", "too many helpers", "junk drawer utils", "over-abstraction", "code quality", "messy components", "should this live in lib", or asks to simplify/refactor modules, layout structure, JSX/markup nesting, Tailwind/class styling, wrappers, helpers, or conditionals while preserving behavior. Guides Codex to inspect usage graphs, runtime boundaries, and ownership; prefer net simplification over cosmetic churn; avoid hiding styling in opaque class-string aliases; and verify behavior.
---

# Debloat Code

## Philosophy

Treat bloat as a responsibility problem, not a line-count problem.

Small files can be good boundaries. Large files can be honest workflow. A helper is not bloat because it exists; it is bloat when it hides one-use logic, crosses runtime boundaries, or creates a vague place where unrelated things accumulate.

Prefer fewer, clearer ownership boundaries over more "clean-looking" files. Do not move code into `lib`, `utils`, `model`, `shared`, or `services` unless multiple real callers need it or the boundary is domain-level and stable.

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
- Inline one-use helpers when the helper name adds less clarity than the code.
- Extract only when it removes real duplication, protects a runtime boundary, or gives a stable concept a name.
- For UI simplification, prefer fewer wrappers, clearer JSX, and inline class names over opaque Tailwind/class-string variables.

5. **Verify behavior**
   - Preserve external behavior unless the user explicitly asks to simplify the product flow.
   - Run the repo's standard check/lint commands.
   - Note pre-existing failures separately from refactor fallout.

## Good Targets

- A `utils.ts` with unrelated parsing, formatting, API, and UI helpers.
- A `model.ts` that exports many one-use helpers and no stable domain model.
- A component that contains API clients, query keys, route search parsing, DOM effects, and JSX in one file.
- Duplicate parsing or normalization logic in client and server modules.
- A generically named file like `api-access.ts` that is really billing, auth, or provider-specific code.
- Unused framework helper files left behind after patterns changed.

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
3. Move API calls into a feature-local `api.ts`.
4. Move query keys/options into feature-local `queries.ts`.
5. Move route search validation into the route or a route-owned helper.
6. Keep the workflow hook feature-local if it depends on React state, router navigation, toast, DOM, or clipboard APIs.
7. Leave JSX focused on rendering.

Do not move the workflow hook to `lib` just because it is long. If it is only used by one feature and owns UI orchestration, it belongs with that feature.

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
3. Keep tiny boundary files when they isolate runtime dependencies, e.g. `db.ts`, `auth-client.ts`, `polar.ts`.
4. Consolidate duplicated pure logic, e.g. balance parsing in both client and server paths.
5. Rename misleading files, e.g. `api-access.ts` to `billing-access.ts` if it is billing-specific.
6. Delete unused files after confirming no imports.

## Runtime Boundary Checklist

Before merging files, ask:

- Would a React component import this file?
- Does the file import DB, server auth, SDK clients, environment secrets, or Node-only packages?
- Does the file import browser/client auth, DOM, clipboard, Blob, or React hooks?
- Can the shared code be made pure and imported by both sides?

Preferred shape:

```txt
credits.ts          # pure shared math/parsing
credits-store.ts    # client query key + client fetch
billing-access.ts   # server auth, credit checks, usage ingestion
```

Do not combine all three just because they are about credits.

## Query Abstraction Rule

For TanStack Query, prefer named query option factories over broad custom query wrappers:

```ts
export const fetchJobQueries = {
  status: (jobId: string | null) =>
    queryOptions({
      queryKey: ["fetch-job", "status", jobId],
      queryFn: () => fetchJobStatus(requiredJobId),
    }),
};
```

Use custom hooks for workflow orchestration only when they own UI transitions and side effects. Do not hide TanStack Query behind generic abstractions that make cache keys, enabled states, or invalidation harder to see.

## Final Response Pattern

When reporting a de-bloat pass:

- Name what moved and why.
- Name what was deleted.
- Mention behavior preservation.
- Mention checks run.
- Separate pre-existing failures from new refactor failures.

# Contract Driven Development (CDD)

> **This is the recommended default convention for Crew projects.**
> When `crew-config.json → conventions.contractDriven` is `true` (default), all API development follows this pattern.

## Overview

The OpenAPI spec is the **single source of truth**. Both backend and frontend generate types and clients from it.

```
docs/openapi.yaml  (Single Source of Truth)
       │
       ├──→ Backend type generation
       │    └── Compile-time contract verification
       │
       └──→ Frontend client generation
            └── Type-safe API calls (no manual fetch/axios)
```

This eliminates an entire class of bugs: mismatched field names, wrong types, stale endpoints, and undocumented breaking changes.

## How It Works

### 1. Write the OpenAPI spec first (be-spec skill)

The API spec is written before any implementation. This forces clear thinking about the contract between frontend and backend.

```bash
# The spec lives at a fixed location
docs/openapi.yaml
```

### 2. Generate backend types

Run code generation to produce type definitions from the spec. The backend implements these types — if the implementation drifts from the spec, the compiler catches it.

```bash
# Example: TypeScript backend
npx openapi-typescript docs/openapi.yaml -o src/api/generated/schema.d.ts
```

### 3. Implement backend to satisfy the contract

Write handlers that accept and return the generated types. The generated types act as an interface — any deviation is a compile error.

```typescript
// The handler's input/output types come from the generated schema
import type { paths } from '@/api/generated/schema';

type CreateUserBody = paths['/users']['post']['requestBody']['content']['application/json'];
type CreateUserResponse = paths['/users']['post']['responses']['201']['content']['application/json'];
```

### 4. Generate frontend API client

Run client generation to produce typed API functions (and optionally React Query / Vue Query hooks).

```bash
# Example: orval generates React Query hooks + types
npx orval
```

### 5. Frontend uses only generated clients

No manual `fetch()` or `axios.get()`. All API calls go through the generated client, which is always in sync with the spec.

```typescript
// Generated hook — types match the spec exactly
import { useGetUsers, useCreateUser } from '@/api/generated/users/users';

const { data } = useGetUsers({ page: 1, limit: 20 });
//      ^-- typed as UserListResponse automatically
```

## Code Generation Tools by Framework

### Backend Type Generation

| Framework | Tool | Command |
|-----------|------|---------|
| NestJS / Express (TS) | openapi-typescript | `npx openapi-typescript docs/openapi.yaml -o src/api/generated/schema.d.ts` |
| FastAPI (Python) | datamodel-code-generator | `datamodel-codegen --input docs/openapi.yaml --output src/schemas/generated.py` |
| Spring Boot (Java) | openapi-generator-cli | `openapi-generator-cli generate -i docs/openapi.yaml -g spring -o src/generated` |
| Go | oapi-codegen | `oapi-codegen -package api docs/openapi.yaml > api/generated.go` |
| .NET | NSwag | `nswag openapi2cscontroller /input:docs/openapi.yaml /output:Generated/Controllers.cs` |

### Frontend Client Generation

| Framework | Tool | Command |
|-----------|------|---------|
| React / Next.js | orval | `npx orval` (generates React Query hooks + types) |
| React / Next.js | openapi-generator-cli | `npx openapi-generator-cli generate -i docs/openapi.yaml -g typescript-axios` |
| Vue | orval | `npx orval` (generates Vue Query composables + types) |
| Svelte | openapi-fetch + openapi-typescript | `npx openapi-typescript docs/openapi.yaml -o src/lib/api/schema.d.ts` + `createClient()` |
| Angular | ng-openapi-gen | `npx ng-openapi-gen --input docs/openapi.yaml` |

### Recommended package.json Scripts

```json
{
  "scripts": {
    "api:generate": "orval",
    "api:generate:backend": "openapi-typescript docs/openapi.yaml -o src/api/generated/schema.d.ts",
    "api:validate": "npx @redocly/cli lint docs/openapi.yaml",
    "api:check": "npm run api:generate && npx tsc --noEmit"
  }
}
```

## Verification

The contract is verified at three levels:

### Compile-time (Backend)

The backend implements generated interfaces. If a field is added to the spec but missing from the handler, the compiler fails.

```typescript
// If the spec says POST /users returns { id, name, email }
// but the handler only returns { id, name }, TypeScript will error
```

### Compile-time (Frontend)

The frontend uses generated client types. If a response field is renamed in the spec, any component referencing the old name gets a type error.

```typescript
// If spec renames 'userName' to 'name', this breaks immediately:
<span>{user.userName}</span>  // TS error: Property 'userName' does not exist
```

### CI Pipeline

Add a check that regenerates clients and runs type checking on every PR.

```yaml
# .github/workflows/contract-check.yml
- name: Validate OpenAPI spec
  run: npx @redocly/cli lint docs/openapi.yaml

- name: Regenerate clients
  run: npm run api:generate

- name: Type check
  run: npx tsc --noEmit

- name: Fail if generated files changed
  run: git diff --exit-code src/api/generated/
```

## The CDD Workflow in Practice

```
1. Product requirement arrives
        │
        ▼
2. be-spec skill writes/updates docs/openapi.yaml
        │
        ▼
3. Review the spec (team agrees on the contract)
        │
        ├──→ 4a. Backend generates types, implements handlers
        │
        └──→ 4b. Frontend generates client, builds UI
        │
        ▼
5. Both sides type-check against the same spec
        │
        ▼
6. CI verifies contract is not broken
```

Backend and frontend can work in parallel after step 3 — the spec is the shared agreement.

## When NOT to Use CDD

Set `conventions.contractDriven: false` in `crew-config.json` when:

- **Prototyping / hackathon**: Speed matters more than type safety
- **GraphQL projects**: Use schema-first development instead (the `.graphql` schema is the contract)
- **Simple scripts / CLI tools**: No API boundary to enforce
- **Third-party API consumption only**: You consume but do not define the spec — use the provider's SDK

In these cases, manual type definitions and direct fetch calls are acceptable.

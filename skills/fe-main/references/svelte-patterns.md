# Svelte / SvelteKit Patterns

> Reference for projects using `crew-config.json → frontend.framework: "svelte"`

## Project Structure (SvelteKit)

```
src/
├── routes/                     # File-based routing
│   ├── +layout.svelte          # Root layout
│   ├── +layout.ts              # Root layout load function
│   ├── +page.svelte            # Home page (/)
│   ├── +error.svelte           # Error page
│   ├── (auth)/                 # Route group (no URL segment)
│   │   ├── login/
│   │   │   ├── +page.svelte
│   │   │   └── +page.server.ts # Server-side load / actions
│   │   └── signup/
│   │       └── +page.svelte
│   ├── dashboard/
│   │   ├── +page.svelte
│   │   └── +page.ts            # Client-safe load function
│   └── users/
│       ├── +page.svelte
│       └── [id]/
│           ├── +page.svelte
│           └── +page.ts
├── lib/
│   ├── api/                    # API client (openapi-fetch or generated)
│   │   ├── client.ts           # createClient() from openapi-fetch
│   │   └── schema.d.ts         # Generated types from openapi-typescript
│   ├── components/
│   │   ├── ui/                 # Base UI (Skeleton UI)
│   │   ├── forms/
│   │   └── layouts/
│   ├── stores/                 # Svelte stores
│   │   └── auth.ts
│   └── utils.ts
├── app.html                    # HTML template
├── app.css                     # Global styles
└── hooks.server.ts             # Server hooks (auth middleware)

# Root config
├── svelte.config.js
├── vite.config.ts
├── tsconfig.json
└── docs/
    └── openapi.yaml
```

## Load Functions (Data Fetching)

### Server Load (runs on server only)

```typescript
// routes/users/+page.server.ts
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ fetch, cookies }) => {
  const token = cookies.get('auth-token');
  const res = await fetch('/api/v1/users?page=1&limit=20', {
    headers: { Authorization: `Bearer ${token}` },
  });

  if (!res.ok) throw error(res.status, 'Failed to load users');

  const data = await res.json();
  return { users: data.users, count: data.count };
};
```

### Universal Load (runs on server and client)

```typescript
// routes/dashboard/+page.ts
import type { PageLoad } from './$types';

export const load: PageLoad = async ({ fetch }) => {
  const res = await fetch('/api/v1/dashboard/stats');
  const stats = await res.json();
  return { stats };
};
```

### Using Load Data in Components

```svelte
<!-- routes/users/+page.svelte -->
<script lang="ts">
  import type { PageData } from './$types';
  import { UserTable } from '$lib/components/ui/UserTable.svelte';

  let { data }: { data: PageData } = $props();
</script>

<h1>Users ({data.count})</h1>
<UserTable users={data.users} />
```

## Form Actions

```typescript
// routes/(auth)/login/+page.server.ts
import type { Actions } from './$types';
import { fail, redirect } from '@sveltejs/kit';

export const actions: Actions = {
  default: async ({ request, cookies, fetch }) => {
    const formData = await request.formData();
    const email = formData.get('email') as string;
    const password = formData.get('password') as string;

    if (!email || !password) {
      return fail(400, { email, message: 'All fields are required' });
    }

    const res = await fetch('/api/v1/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });

    if (!res.ok) {
      return fail(401, { email, message: 'Invalid credentials' });
    }

    const { accessToken } = await res.json();
    cookies.set('auth-token', accessToken, { path: '/', httpOnly: true });
    redirect(303, '/dashboard');
  },
};
```

```svelte
<!-- routes/(auth)/login/+page.svelte -->
<script lang="ts">
  import { enhance } from '$app/forms';
  import type { ActionData } from './$types';

  let { form }: { form: ActionData } = $props();
</script>

<form method="POST" use:enhance>
  {#if form?.message}
    <p class="text-red-500">{form.message}</p>
  {/if}
  <input name="email" type="email" value={form?.email ?? ''} />
  <input name="password" type="password" />
  <button type="submit">Log In</button>
</form>
```

## Svelte Stores

```typescript
// lib/stores/auth.ts
import { writable, derived } from 'svelte/store';

export const authToken = writable<string | null>(null);
export const isAuthenticated = derived(authToken, ($token) => !!$token);

// Usage in component:
// import { authToken } from '$lib/stores/auth';
// $authToken = 'new-token';           // set
// console.log($authToken);             // read (auto-subscribed)
```

### Svelte 5 Runes Alternative

```typescript
// lib/stores/auth.svelte.ts
class AuthState {
  token = $state<string | null>(null);
  get isAuthenticated() { return !!this.token; }

  setToken(t: string) { this.token = t; }
  clearToken() { this.token = null; }
}

export const authState = new AuthState();
```

## Component Patterns (Svelte 5)

### Props and Events

```svelte
<!-- lib/components/ui/Button.svelte -->
<script lang="ts">
  import type { Snippet } from 'svelte';

  let {
    variant = 'primary',
    disabled = false,
    loading = false,
    onclick,
    children,
  }: {
    variant?: 'primary' | 'secondary' | 'ghost';
    disabled?: boolean;
    loading?: boolean;
    onclick?: () => void;
    children: Snippet;
  } = $props();
</script>

<button class="btn btn-{variant}" {disabled} {onclick}>
  {#if loading}
    <span class="spinner" />
  {/if}
  {@render children()}
</button>
```

### Slots (Svelte 5 Snippets)

```svelte
<!-- lib/components/ui/Card.svelte -->
<script lang="ts">
  import type { Snippet } from 'svelte';

  let { header, children, footer }: {
    header?: Snippet;
    children: Snippet;
    footer?: Snippet;
  } = $props();
</script>

<div class="card">
  {#if header}
    <div class="card-header">{@render header()}</div>
  {/if}
  <div class="card-body">{@render children()}</div>
  {#if footer}
    <div class="card-footer">{@render footer()}</div>
  {/if}
</div>
```

## API Client — openapi-fetch

```typescript
// lib/api/client.ts
import createClient from 'openapi-fetch';
import type { paths } from './schema';  // Generated by openapi-typescript

export const api = createClient<paths>({
  baseUrl: 'http://localhost:3000/api/v1',
});

// Usage:
// const { data, error } = await api.GET('/users/{id}', { params: { path: { id } } });
```

## UI — Skeleton UI

```svelte
<script lang="ts">
  import { AppBar, Avatar, ListBox, ListBoxItem } from '@skeletonlabs/skeleton';
</script>

<AppBar>
  <svelte:fragment slot="lead">
    <strong>My App</strong>
  </svelte:fragment>
  <svelte:fragment slot="trail">
    <Avatar initials="JD" />
  </svelte:fragment>
</AppBar>
```

## Key Conventions

1. Use SvelteKit load functions for data fetching — server loads for auth-protected data
2. Use form actions for mutations (progressive enhancement, works without JS)
3. Prefer Svelte 5 runes (`$props`, `$state`, `$derived`) over legacy syntax
4. Use `openapi-typescript` + `openapi-fetch` for type-safe API calls
5. Keep stores minimal — most data flows through load functions
6. Use `$lib` alias for all imports from `src/lib/`

# Next.js Patterns (App Router)

> Reference for projects using `crew-config.json → frontend.framework: "nextjs"`

## Project Structure

```
src/
├── app/                        # App Router
│   ├── (auth)/                 # Route group (no URL segment)
│   │   ├── login/page.tsx
│   │   └── signup/page.tsx
│   ├── (dashboard)/
│   │   ├── layout.tsx          # Shared dashboard layout
│   │   ├── page.tsx            # /dashboard
│   │   └── settings/page.tsx
│   ├── api/                    # Route Handlers
│   │   └── webhooks/route.ts
│   ├── layout.tsx              # Root layout
│   ├── loading.tsx             # Global loading UI
│   ├── error.tsx               # Global error boundary
│   └── providers.tsx           # Client providers (QueryClient, etc.)
├── api/                        # Generated API clients (orval output)
│   ├── generated/
│   ├── model/
│   └── custom-instance.ts
├── components/
│   ├── ui/                     # Base UI (shadcn/ui)
│   ├── forms/                  # Form components
│   └── layouts/                # Layout components (header, sidebar)
├── hooks/                      # Custom hooks wrapping generated ones
├── stores/                     # Zustand stores (client state only)
├── lib/
│   ├── schemas/                # Zod validation schemas
│   └── utils.ts                # cn() helper, etc.
└── styles/
    └── globals.css             # Tailwind directives + custom tokens
```

## Server vs Client Components

```tsx
// Server Component (default) — runs on the server, no useState/useEffect
// app/(dashboard)/page.tsx
import { getUserProfile } from '@/lib/api/server';

export default async function DashboardPage() {
  const profile = await getUserProfile();   // Direct fetch, no hook needed
  return <h1>Welcome, {profile.name}</h1>;
}
```

```tsx
// Client Component — add 'use client' when you need interactivity
// components/forms/search-form.tsx
'use client';

import { useState } from 'react';

export function SearchForm() {
  const [query, setQuery] = useState('');
  return <input value={query} onChange={(e) => setQuery(e.target.value)} />;
}
```

### When to use each

| Use Server Component when | Use Client Component when |
|---------------------------|--------------------------|
| Fetching data | useState, useEffect, event handlers |
| Accessing backend resources | Browser APIs (localStorage, etc.) |
| Rendering static/SEO content | Interactive forms, modals, dropdowns |
| Keeping secrets server-side | Using React Query / Zustand hooks |

## Data Fetching

### Server-side (Server Components / Server Actions)

```tsx
// Server Action — app/actions/users.ts
'use server';

import { revalidatePath } from 'next/cache';

export async function createUser(formData: FormData) {
  const res = await fetch(`${process.env.API_URL}/users`, {
    method: 'POST',
    body: JSON.stringify({ name: formData.get('name') }),
    headers: { 'Content-Type': 'application/json' },
  });
  if (!res.ok) throw new Error('Failed to create user');
  revalidatePath('/users');
}
```

### Client-side (React Query via orval)

```tsx
'use client';

import { useGetUsers } from '@/api/generated/users/users';

export function UserList() {
  const { data, isLoading, error } = useGetUsers({ page: 1, limit: 20 });

  if (isLoading) return <Skeleton />;
  if (error) return <ErrorMessage error={error} />;

  return data?.users.map((u) => <UserCard key={u.id} user={u} />);
}
```

## State Management

### Client State — Zustand

```typescript
// stores/ui-store.ts
import { create } from 'zustand';

interface UIState {
  sidebarOpen: boolean;
  toggleSidebar: () => void;
}

export const useUIStore = create<UIState>()((set) => ({
  sidebarOpen: true,
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
}));
```

### Server State — React Query (generated)

Server state lives in React Query cache. Never duplicate API data into Zustand.

## API Route Handlers

```typescript
// app/api/webhooks/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest) {
  const body = await request.json();
  // Process webhook...
  return NextResponse.json({ received: true }, { status: 200 });
}
```

## Styling — Tailwind + shadcn/ui

```tsx
// Use shadcn/ui primitives, compose with Tailwind classes
import { Button } from '@/components/ui/button';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';

export function FeatureCard({ title, children }: Props) {
  return (
    <Card className="hover:shadow-md transition-shadow">
      <CardHeader>
        <CardTitle className="text-lg">{title}</CardTitle>
      </CardHeader>
      <CardContent>{children}</CardContent>
    </Card>
  );
}
```

### cn() utility for conditional classes

```typescript
// lib/utils.ts
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

## Routing Patterns

| Pattern | File | URL |
|---------|------|-----|
| Static | `app/about/page.tsx` | `/about` |
| Dynamic | `app/users/[id]/page.tsx` | `/users/123` |
| Catch-all | `app/docs/[...slug]/page.tsx` | `/docs/a/b/c` |
| Route group | `app/(auth)/login/page.tsx` | `/login` |
| Parallel | `app/@modal/login/page.tsx` | Modal overlay |

## Key Conventions

1. Default to Server Components; add `'use client'` only when needed
2. Use Server Actions for mutations that need revalidation
3. Use React Query (generated) for client-side data fetching and caching
4. Keep Zustand stores small and focused on UI/client state only
5. Use `loading.tsx` and `error.tsx` for route-level loading/error states
6. Colocate page-specific components in the route folder when not reused

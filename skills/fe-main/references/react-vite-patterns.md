# React + Vite Patterns

> Reference for projects using `crew-config.json → frontend.framework: "react-vite"`

## Project Structure

```
src/
├── main.tsx                    # Entry point (ReactDOM.createRoot)
├── App.tsx                     # Root component with RouterProvider
├── router/
│   └── index.tsx               # React Router route definitions
├── api/                        # Generated API clients (orval output)
│   ├── generated/
│   ├── model/
│   └── custom-instance.ts
├── components/
│   ├── ui/                     # Base UI (shadcn/ui or MUI)
│   ├── forms/                  # Form components
│   └── layouts/                # Layout components
├── pages/                      # Page-level components
│   ├── auth/
│   │   ├── LoginPage.tsx
│   │   └── SignupPage.tsx
│   ├── dashboard/
│   │   └── DashboardPage.tsx
│   └── users/
│       ├── UserListPage.tsx
│       └── UserDetailPage.tsx
├── hooks/                      # Custom hooks wrapping generated ones
├── stores/                     # Zustand stores
├── lib/
│   ├── schemas/                # Zod validation schemas
│   └── utils.ts
├── styles/
│   └── globals.css
├── vite-env.d.ts
└── index.html                  # Vite HTML entry

# Root config
├── vite.config.ts
├── tsconfig.json
├── orval.config.ts             # API client generation
└── docs/
    └── openapi.yaml
```

## Routing — React Router v7

### Route Definitions

```tsx
// router/index.tsx
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import { RootLayout } from '@/components/layouts/RootLayout';
import { AuthLayout } from '@/components/layouts/AuthLayout';
import { DashboardPage } from '@/pages/dashboard/DashboardPage';
import { LoginPage } from '@/pages/auth/LoginPage';

const router = createBrowserRouter([
  {
    element: <RootLayout />,
    errorElement: <ErrorBoundary />,
    children: [
      {
        element: <AuthLayout />,       // No auth required
        children: [
          { path: '/login', element: <LoginPage /> },
          { path: '/signup', element: <SignupPage /> },
        ],
      },
      {
        element: <ProtectedLayout />,  // Auth required
        children: [
          { path: '/', element: <DashboardPage /> },
          { path: '/users', element: <UserListPage /> },
          { path: '/users/:id', element: <UserDetailPage /> },
        ],
      },
    ],
  },
]);

export function AppRouter() {
  return <RouterProvider router={router} />;
}
```

### Layout with Outlet

```tsx
// components/layouts/RootLayout.tsx
import { Outlet } from 'react-router-dom';
import { Header } from './Header';

export function RootLayout() {
  return (
    <div className="min-h-screen flex flex-col">
      <Header />
      <main className="flex-1">
        <Outlet />
      </main>
    </div>
  );
}
```

### Route Parameters and Navigation

```tsx
import { useParams, useNavigate, useSearchParams } from 'react-router-dom';

function UserDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();

  return (
    <button onClick={() => navigate('/users')}>Back to list</button>
  );
}
```

## Data Fetching — TanStack Query (via orval)

```tsx
// Generated hooks are used directly in components
import { useGetUsers, useCreateUser } from '@/api/generated/users/users';
import { useQueryClient } from '@tanstack/react-query';

function UserListPage() {
  const queryClient = useQueryClient();
  const { data, isLoading } = useGetUsers({ page: 1, limit: 20 });
  const createMutation = useCreateUser();

  const handleCreate = async (userData: CreateUserRequest) => {
    await createMutation.mutateAsync(userData);
    queryClient.invalidateQueries({ queryKey: ['users'] });
  };

  if (isLoading) return <Skeleton />;
  return <UserTable users={data?.users ?? []} onCreate={handleCreate} />;
}
```

### Query Provider Setup

```tsx
// App.tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { AppRouter } from '@/router';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: { staleTime: 60_000, retry: 1, refetchOnWindowFocus: false },
  },
});

export function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AppRouter />
      <ReactQueryDevtools />
    </QueryClientProvider>
  );
}
```

## State Management — Zustand

```typescript
// stores/auth-store.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface AuthState {
  token: string | null;
  setToken: (token: string) => void;
  clearToken: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      token: null,
      setToken: (token) => set({ token }),
      clearToken: () => set({ token: null }),
    }),
    { name: 'auth-storage' }
  )
);
```

Keep Zustand for client-only state (auth tokens, UI preferences, modals). Server data belongs in React Query cache.

## Component Library

### With shadcn/ui (Tailwind-based)

```tsx
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader } from '@/components/ui/dialog';
```

### With MUI

```tsx
import { Button, TextField, Dialog } from '@mui/material';
import { ThemeProvider, createTheme } from '@mui/material/styles';

const theme = createTheme({
  palette: { primary: { main: '#1976d2' } },
});

// Wrap App with <ThemeProvider theme={theme}>
```

## Vite Configuration

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: { '@': path.resolve(__dirname, './src') },
  },
  server: {
    proxy: {
      '/api': { target: 'http://localhost:3000', changeOrigin: true },
    },
  },
});
```

## Key Conventions

1. All components are client-side (no server/client split like Next.js)
2. Use React Router layouts (`<Outlet />`) to share structure across routes
3. Use generated React Query hooks for all API calls — no raw fetch/axios
4. Zustand for client state, React Query for server state
5. Use Vite proxy for local API development to avoid CORS issues
6. Prefer named exports for page and component files

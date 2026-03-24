# Vue 3 Patterns (Composition API)

> Reference for projects using `crew-config.json → frontend.framework: "vue"`

## Project Structure

```
src/
├── main.ts                     # App entry (createApp)
├── App.vue                     # Root component
├── router/
│   └── index.ts                # Vue Router definitions
├── api/                        # Generated API clients (orval output)
│   ├── generated/
│   ├── model/
│   └── custom-instance.ts
├── components/
│   ├── ui/                     # Base UI (Vuetify / Element Plus)
│   ├── forms/                  # Form components
│   └── layouts/                # Layout components
├── views/                      # Page-level components
│   ├── auth/
│   │   ├── LoginView.vue
│   │   └── SignupView.vue
│   └── dashboard/
│       └── DashboardView.vue
├── composables/                # Reusable composition functions (use*)
│   ├── useAuth.ts
│   └── useForm.ts
├── stores/                     # Pinia stores
│   └── auth.ts
├── lib/
│   ├── schemas/                # Zod / Valibot schemas
│   └── utils.ts
├── types/                      # App-level TypeScript types
└── styles/
    └── main.css

# Root config
├── vite.config.ts
├── tsconfig.json
├── orval.config.ts
└── docs/
    └── openapi.yaml
```

## Composition API Patterns

### Component with Props and Emits

```vue
<!-- components/ui/UserCard.vue -->
<script setup lang="ts">
import type { User } from '@/api/model';

const props = defineProps<{
  user: User;
  selected?: boolean;
}>();

const emit = defineEmits<{
  select: [userId: string];
  delete: [userId: string];
}>();
</script>

<template>
  <div
    :class="['user-card', { 'user-card--selected': selected }]"
    @click="emit('select', user.id)"
  >
    <h3>{{ user.name }}</h3>
    <p>{{ user.email }}</p>
    <button @click.stop="emit('delete', user.id)">Delete</button>
  </div>
</template>
```

### Composable (Reusable Logic)

```typescript
// composables/useAuth.ts
import { computed } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import { useLogin, useLogout, useGetMe } from '@/api/generated/auth/auth';

export function useAuth() {
  const router = useRouter();
  const authStore = useAuthStore();

  const loginMutation = useLogin();
  const logoutMutation = useLogout();
  const { data: user, isLoading } = useGetMe({
    query: { enabled: computed(() => !!authStore.token) },
  });

  async function login(credentials: { email: string; password: string }) {
    const result = await loginMutation.mutateAsync(credentials);
    authStore.setToken(result.accessToken);
    router.push('/dashboard');
  }

  async function logout() {
    await logoutMutation.mutateAsync();
    authStore.clearToken();
    router.push('/login');
  }

  return { user, isLoading, login, logout, isAuthenticated: computed(() => !!authStore.token) };
}
```

### Slots

```vue
<!-- components/ui/Card.vue -->
<script setup lang="ts">
defineProps<{ title?: string }>();
</script>

<template>
  <div class="card">
    <div v-if="$slots.header || title" class="card-header">
      <slot name="header">
        <h3>{{ title }}</h3>
      </slot>
    </div>
    <div class="card-body">
      <slot />
    </div>
    <div v-if="$slots.footer" class="card-footer">
      <slot name="footer" />
    </div>
  </div>
</template>
```

## Routing — Vue Router

```typescript
// router/index.ts
import { createRouter, createWebHistory } from 'vue-router';
import { useAuthStore } from '@/stores/auth';

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      component: () => import('@/components/layouts/MainLayout.vue'),
      meta: { requiresAuth: true },
      children: [
        { path: '', name: 'dashboard', component: () => import('@/views/dashboard/DashboardView.vue') },
        { path: 'users', name: 'users', component: () => import('@/views/users/UserListView.vue') },
        { path: 'users/:id', name: 'user-detail', component: () => import('@/views/users/UserDetailView.vue') },
      ],
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/auth/LoginView.vue'),
    },
  ],
});

router.beforeEach((to) => {
  const authStore = useAuthStore();
  if (to.meta.requiresAuth && !authStore.token) {
    return { name: 'login', query: { redirect: to.fullPath } };
  }
});

export default router;
```

## State Management — Pinia

```typescript
// stores/auth.ts
import { defineStore } from 'pinia';
import { ref } from 'vue';

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string | null>(localStorage.getItem('auth-token'));

  function setToken(newToken: string) {
    token.value = newToken;
    localStorage.setItem('auth-token', newToken);
  }

  function clearToken() {
    token.value = null;
    localStorage.removeItem('auth-token');
  }

  return { token, setToken, clearToken };
});
```

## Data Fetching — Vue Query (TanStack Query via orval)

```vue
<!-- views/users/UserListView.vue -->
<script setup lang="ts">
import { useGetUsers } from '@/api/generated/users/users';

const { data, isLoading, error } = useGetUsers({ page: 1, limit: 20 });
</script>

<template>
  <div v-if="isLoading">Loading...</div>
  <div v-else-if="error">Error: {{ error.message }}</div>
  <ul v-else>
    <li v-for="user in data?.users" :key="user.id">{{ user.name }}</li>
  </ul>
</template>
```

### Vue Query Plugin Setup

```typescript
// main.ts
import { createApp } from 'vue';
import { createPinia } from 'pinia';
import { VueQueryPlugin } from '@tanstack/vue-query';
import router from '@/router';
import App from './App.vue';

const app = createApp(App);
app.use(createPinia());
app.use(router);
app.use(VueQueryPlugin, {
  queryClientConfig: {
    defaultOptions: {
      queries: { staleTime: 60_000, retry: 1, refetchOnWindowFocus: false },
    },
  },
});
app.mount('#app');
```

## UI Libraries

### Vuetify

```vue
<script setup lang="ts">
import { ref } from 'vue';
const dialog = ref(false);
</script>

<template>
  <v-btn color="primary" @click="dialog = true">Open</v-btn>
  <v-dialog v-model="dialog" max-width="500">
    <v-card>
      <v-card-title>Title</v-card-title>
      <v-card-text>Content</v-card-text>
      <v-card-actions>
        <v-btn @click="dialog = false">Close</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
```

### Element Plus

```vue
<template>
  <el-button type="primary" @click="handleClick">Submit</el-button>
  <el-table :data="users">
    <el-table-column prop="name" label="Name" />
    <el-table-column prop="email" label="Email" />
  </el-table>
</template>
```

## Key Conventions

1. Use `<script setup lang="ts">` for all components (Composition API)
2. Use `defineProps` / `defineEmits` with TypeScript generics for type safety
3. Extract reusable logic into composables (`composables/use*.ts`)
4. Pinia for client state, Vue Query for server state — never duplicate
5. Lazy-load route components with dynamic `import()` for code splitting
6. Use generated API hooks from orval — no manual fetch/axios calls

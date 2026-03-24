# Angular Patterns (Standalone Components)

> Reference for projects using `crew-config.json → frontend.framework: "angular"`

## Project Structure

```
src/
├── main.ts                     # bootstrapApplication()
├── app/
│   ├── app.config.ts           # provideRouter, provideHttpClient, etc.
│   ├── app.component.ts        # Root component
│   ├── app.routes.ts           # Route definitions
│   ├── core/
│   │   ├── interceptors/
│   │   │   └── auth.interceptor.ts
│   │   ├── guards/
│   │   │   └── auth.guard.ts
│   │   └── services/
│   │       └── auth.service.ts
│   ├── api/                    # Generated API clients (ng-openapi-gen output)
│   │   ├── services/           # Generated API services
│   │   ├── models/             # Generated types
│   │   └── api.module.ts
│   ├── features/               # Feature modules (lazy-loaded)
│   │   ├── auth/
│   │   │   ├── login/
│   │   │   │   └── login.component.ts
│   │   │   └── auth.routes.ts
│   │   ├── dashboard/
│   │   │   ├── dashboard.component.ts
│   │   │   └── dashboard.routes.ts
│   │   └── users/
│   │       ├── user-list/
│   │       │   └── user-list.component.ts
│   │       ├── user-detail/
│   │       │   └── user-detail.component.ts
│   │       └── users.routes.ts
│   ├── shared/
│   │   ├── components/         # Reusable UI components
│   │   ├── directives/
│   │   └── pipes/
│   └── store/                  # NgRx or signal-based state
│       └── auth.store.ts
├── styles.scss
└── environments/
    ├── environment.ts
    └── environment.prod.ts

# Root config
├── angular.json
├── tsconfig.json
└── docs/
    └── openapi.yaml
```

## Standalone Components

```typescript
// features/users/user-list/user-list.component.ts
import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { UsersApiService } from '@/api/services/users-api.service';
import type { User } from '@/api/models/user';

@Component({
  selector: 'app-user-list',
  standalone: true,
  imports: [CommonModule, RouterLink, MatTableModule, MatButtonModule],
  template: `
    <h1>Users</h1>
    @if (loading()) {
      <mat-spinner />
    } @else {
      <mat-table [dataSource]="users()">
        <ng-container matColumnDef="name">
          <mat-header-cell *matHeaderCellDef>Name</mat-header-cell>
          <mat-cell *matCellDef="let user">{{ user.name }}</mat-cell>
        </ng-container>
        <ng-container matColumnDef="actions">
          <mat-header-cell *matHeaderCellDef />
          <mat-cell *matCellDef="let user">
            <a mat-button [routerLink]="['/users', user.id]">View</a>
          </mat-cell>
        </ng-container>
        <mat-header-row *matHeaderRowDef="['name', 'actions']" />
        <mat-row *matRowDef="let row; columns: ['name', 'actions']" />
      </mat-table>
    }
  `,
})
export class UserListComponent {
  private usersApi = inject(UsersApiService);

  users = signal<User[]>([]);
  loading = signal(true);

  constructor() {
    this.usersApi.getUsers({ page: 1, limit: 20 }).subscribe({
      next: (res) => {
        this.users.set(res.users);
        this.loading.set(false);
      },
      error: () => this.loading.set(false),
    });
  }
}
```

## Routing

```typescript
// app/app.routes.ts
import { Routes } from '@angular/router';
import { authGuard } from '@/core/guards/auth.guard';

export const routes: Routes = [
  {
    path: '',
    canActivate: [authGuard],
    children: [
      { path: '', loadComponent: () => import('./features/dashboard/dashboard.component').then(m => m.DashboardComponent) },
      { path: 'users', loadChildren: () => import('./features/users/users.routes').then(m => m.USERS_ROUTES) },
    ],
  },
  { path: 'login', loadComponent: () => import('./features/auth/login/login.component').then(m => m.LoginComponent) },
];
```

```typescript
// features/users/users.routes.ts
import { Routes } from '@angular/router';

export const USERS_ROUTES: Routes = [
  { path: '', loadComponent: () => import('./user-list/user-list.component').then(m => m.UserListComponent) },
  { path: ':id', loadComponent: () => import('./user-detail/user-detail.component').then(m => m.UserDetailComponent) },
];
```

### Auth Guard

```typescript
// core/guards/auth.guard.ts
import { inject } from '@angular/core';
import { Router, type CanActivateFn } from '@angular/router';
import { AuthService } from '@/core/services/auth.service';

export const authGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);
  return auth.isAuthenticated() ? true : router.createUrlTree(['/login']);
};
```

## HttpClient + Interceptors

### App Configuration

```typescript
// app/app.config.ts
import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { routes } from './app.routes';
import { authInterceptor } from '@/core/interceptors/auth.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideHttpClient(withInterceptors([authInterceptor])),
    provideAnimationsAsync(),
  ],
};
```

### Auth Interceptor

```typescript
// core/interceptors/auth.interceptor.ts
import { inject } from '@angular/core';
import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';
import { AuthService } from '@/core/services/auth.service';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);
  const router = inject(Router);

  const authReq = auth.token()
    ? req.clone({ setHeaders: { Authorization: `Bearer ${auth.token()}` } })
    : req;

  return next(authReq).pipe(
    catchError((err: HttpErrorResponse) => {
      if (err.status === 401) {
        auth.clearToken();
        router.navigate(['/login']);
      }
      return throwError(() => err);
    })
  );
};
```

## State Management — Signals

```typescript
// core/services/auth.service.ts
import { Injectable, signal, computed } from '@angular/core';

@Injectable({ providedIn: 'root' })
export class AuthService {
  token = signal<string | null>(localStorage.getItem('auth-token'));
  isAuthenticated = computed(() => !!this.token());

  setToken(t: string) {
    this.token.set(t);
    localStorage.setItem('auth-token', t);
  }

  clearToken() {
    this.token.set(null);
    localStorage.removeItem('auth-token');
  }
}
```

### NgRx SignalStore (for complex state)

```typescript
// store/auth.store.ts
import { signalStore, withState, withMethods, patchState } from '@ngrx/signals';

type AuthState = { token: string | null; loading: boolean };

export const AuthStore = signalStore(
  withState<AuthState>({ token: null, loading: false }),
  withMethods((store) => ({
    setToken(token: string) { patchState(store, { token }); },
    clearToken() { patchState(store, { token: null }); },
  }))
);
```

## Angular Material

```typescript
// Inline template example
@Component({
  standalone: true,
  imports: [MatButtonModule, MatFormFieldModule, MatInputModule],
  template: `
    <mat-form-field appearance="outline">
      <mat-label>Email</mat-label>
      <input matInput type="email" [formControl]="email" />
      @if (email.hasError('required')) {
        <mat-error>Email is required</mat-error>
      }
    </mat-form-field>
    <button mat-raised-button color="primary" (click)="submit()">Submit</button>
  `,
})
```

## Key Conventions

1. Use standalone components everywhere (no NgModules for feature code)
2. Use functional interceptors and guards (not class-based)
3. Use Angular Signals for simple state; NgRx SignalStore for complex state
4. Use generated API services from ng-openapi-gen — no manual HttpClient calls
5. Lazy-load feature routes with `loadComponent` / `loadChildren`
6. Use the new `@if` / `@for` control flow syntax instead of `*ngIf` / `*ngFor`

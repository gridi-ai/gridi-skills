# Playwright Test Patterns Guide

## Authentication Handling

### Saving Login State

```typescript
// global.setup.ts
import { chromium, FullConfig } from '@playwright/test';
import { testUsers } from './fixtures/test-data';

async function globalSetup(config: FullConfig) {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  await page.goto('/login');
  await page.getByLabel('Email').fill(testUsers.valid.email);
  await page.getByLabel('Password').fill(testUsers.valid.password);
  await page.getByRole('button', { name: 'Log In' }).click();

  // Save state
  await page.context().storageState({ path: './playwright/.auth/user.json' });

  await browser.close();
}

export default globalSetup;

// playwright.config.ts
export default defineConfig({
  globalSetup: require.resolve('./global.setup'),
  projects: [
    {
      name: 'authenticated',
      use: {
        storageState: './playwright/.auth/user.json',
      },
    },
  ],
});
```

### Multiple User Roles

```typescript
// Admin setup
const adminFile = 'playwright/.auth/admin.json';

test.describe('Admin Tests', () => {
  test.use({ storageState: adminFile });

  test('Access admin dashboard', async ({ page }) => {
    await page.goto('/admin');
    await expect(page).toHaveURL('/admin');
  });
});

// Standard user setup
const userFile = 'playwright/.auth/user.json';

test.describe('User Tests', () => {
  test.use({ storageState: userFile });

  test('Cannot access admin page', async ({ page }) => {
    await page.goto('/admin');
    await expect(page).toHaveURL('/unauthorized');
  });
});
```

## API Mocking

### Network Intercept

```typescript
test('API error handling', async ({ page }) => {
  // API mocking
  await page.route('/api/users', async (route) => {
    await route.fulfill({
      status: 500,
      contentType: 'application/json',
      body: JSON.stringify({ error: 'Server Error' }),
    });
  });

  await page.goto('/users');
  await expect(page.getByText('An error occurred')).toBeVisible();
});

test('Slow network simulation', async ({ page }) => {
  await page.route('/api/data', async (route) => {
    await new Promise(resolve => setTimeout(resolve, 3000));
    await route.continue();
  });

  await page.goto('/data');
  await expect(page.getByText('Loading...')).toBeVisible();
});
```

### API Response Modification

```typescript
test('Data mocking', async ({ page }) => {
  await page.route('/api/users', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({
        data: [
          { id: 1, name: 'Test User 1' },
          { id: 2, name: 'Test User 2' },
        ],
      }),
    });
  });

  await page.goto('/users');
  await expect(page.getByText('Test User 1')).toBeVisible();
  await expect(page.getByText('Test User 2')).toBeVisible();
});
```

## Form Testing

### Input and Validation

```typescript
test('Form validation', async ({ page }) => {
  await page.goto('/signup');

  // Empty submission
  await page.getByRole('button', { name: 'Sign Up' }).click();
  await expect(page.getByText('Please enter your email')).toBeVisible();

  // Invalid format
  await page.getByLabel('Email').fill('invalid');
  await page.getByRole('button', { name: 'Sign Up' }).click();
  await expect(page.getByText('Please enter a valid email')).toBeVisible();

  // Valid input
  await page.getByLabel('Email').fill('test@example.com');
  await page.getByLabel('Password').fill('Test1234!');
  await page.getByRole('button', { name: 'Sign Up' }).click();

  await expect(page).toHaveURL('/welcome');
});
```

### File Upload

```typescript
test('File upload', async ({ page }) => {
  await page.goto('/upload');

  // Select file
  const fileChooserPromise = page.waitForEvent('filechooser');
  await page.getByRole('button', { name: 'Choose File' }).click();
  const fileChooser = await fileChooserPromise;
  await fileChooser.setFiles('test-files/image.png');

  // Verify upload complete
  await expect(page.getByText('Upload complete')).toBeVisible();
});

// Drag and drop
test('Drag and drop upload', async ({ page }) => {
  await page.goto('/upload');

  const dataTransfer = await page.evaluateHandle(() => new DataTransfer());
  await page.dispatchEvent('[data-testid="dropzone"]', 'drop', { dataTransfer });
});
```

## Modals/Dialogs

### Modal Testing

```typescript
test('Modal open/close', async ({ page }) => {
  await page.goto('/dashboard');

  // Open modal
  await page.getByRole('button', { name: 'New Item' }).click();
  await expect(page.getByRole('dialog')).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Create New Item' })).toBeVisible();

  // Close with ESC
  await page.keyboard.press('Escape');
  await expect(page.getByRole('dialog')).not.toBeVisible();

  // Reopen and close by clicking outside
  await page.getByRole('button', { name: 'New Item' }).click();
  await page.locator('[data-testid="modal-backdrop"]').click();
  await expect(page.getByRole('dialog')).not.toBeVisible();
});
```

### Confirmation Dialog

```typescript
test('Confirmation dialog', async ({ page }) => {
  await page.goto('/items');

  // Handle browser confirm
  page.on('dialog', async (dialog) => {
    expect(dialog.message()).toBe('Are you sure you want to delete?');
    await dialog.accept();
  });

  await page.getByRole('button', { name: 'Delete' }).click();
  await expect(page.getByText('Deleted successfully')).toBeVisible();
});
```

## Navigation Testing

### Page Navigation

```typescript
test('Navigation', async ({ page }) => {
  await page.goto('/');

  // Click link
  await page.getByRole('link', { name: 'About' }).click();
  await expect(page).toHaveURL('/about');

  // Go back
  await page.goBack();
  await expect(page).toHaveURL('/');

  // Go forward
  await page.goForward();
  await expect(page).toHaveURL('/about');
});
```

### SPA Routing

```typescript
test('SPA navigation', async ({ page }) => {
  await page.goto('/');

  // Client-side navigation
  await page.getByRole('link', { name: 'Dashboard' }).click();

  // Wait for URL change
  await page.waitForURL('/dashboard');

  // Verify content
  await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();
});
```

## Responsive Testing

### Viewport Settings

```typescript
test.describe('Mobile View', () => {
  test.use({ viewport: { width: 375, height: 667 } });

  test('Mobile menu', async ({ page }) => {
    await page.goto('/');

    // Verify hamburger menu is visible
    await expect(page.getByRole('button', { name: 'Menu' })).toBeVisible();

    // Open menu
    await page.getByRole('button', { name: 'Menu' }).click();
    await expect(page.getByRole('navigation')).toBeVisible();
  });
});

test.describe('Desktop View', () => {
  test.use({ viewport: { width: 1920, height: 1080 } });

  test('Navigation bar', async ({ page }) => {
    await page.goto('/');

    // Navigation always visible
    await expect(page.getByRole('navigation')).toBeVisible();
    // Hamburger menu hidden
    await expect(page.getByRole('button', { name: 'Menu' })).not.toBeVisible();
  });
});
```

## Accessibility Testing

```typescript
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('Accessibility check', async ({ page }) => {
  await page.goto('/');

  const results = await new AxeBuilder({ page }).analyze();

  expect(results.violations).toEqual([]);
});

test('Keyboard navigation', async ({ page }) => {
  await page.goto('/login');

  // Verify tab order
  await page.keyboard.press('Tab');
  await expect(page.getByLabel('Email')).toBeFocused();

  await page.keyboard.press('Tab');
  await expect(page.getByLabel('Password')).toBeFocused();

  await page.keyboard.press('Tab');
  await expect(page.getByRole('button', { name: 'Log In' })).toBeFocused();
});
```

## Parallel Execution and Isolation

```typescript
// Isolation between tests
test.describe.configure({ mode: 'parallel' });

test.describe('User A Tests', () => {
  test('Test 1', async ({ page }) => { /* ... */ });
  test('Test 2', async ({ page }) => { /* ... */ });
});

// When sequential execution is needed
test.describe.configure({ mode: 'serial' });

test.describe('Order-dependent Tests', () => {
  test('Step 1: Create', async ({ page }) => { /* ... */ });
  test('Step 2: Update', async ({ page }) => { /* ... */ });
  test('Step 3: Delete', async ({ page }) => { /* ... */ });
});
```

# Mocking Guide

## Jest Mocking

### Module Mocking

```typescript
// Full module mocking
jest.mock('@/services/email.service');

// Partial mocking
jest.mock('@/services/email.service', () => ({
  ...jest.requireActual('@/services/email.service'),
  sendEmail: jest.fn(),
}));
```

### Function Mocking

```typescript
// Set return value
mockFn.mockReturnValue('value');
mockFn.mockReturnValueOnce('first').mockReturnValueOnce('second');

// Promise return
mockFn.mockResolvedValue(data);
mockFn.mockRejectedValue(new Error('Failed'));

// Implementation mocking
mockFn.mockImplementation((arg) => arg * 2);
```

### Class Mocking

```typescript
// Automatic mocking
jest.mock('@/repositories/user.repository');
const MockUserRepository = UserRepository as jest.MockedClass<typeof UserRepository>;

// Instance method mocking
const mockInstance = new MockUserRepository();
mockInstance.findById.mockResolvedValue(user);
```

### Call Verification

```typescript
// Call check
expect(mockFn).toHaveBeenCalled();
expect(mockFn).toHaveBeenCalledTimes(2);

// Argument verification
expect(mockFn).toHaveBeenCalledWith('arg1', 'arg2');
expect(mockFn).toHaveBeenLastCalledWith('lastArg');

// Call order
expect(mockFn1).toHaveBeenCalledBefore(mockFn2);
```

## External Service Mocking

### HTTP Request Mocking (nock)

```typescript
import nock from 'nock';

beforeEach(() => {
  nock('https://api.external.com')
    .get('/users/1')
    .reply(200, { id: 1, name: 'John' });
});

afterEach(() => {
  nock.cleanAll();
});

it('should fetch external user', async () => {
  const user = await externalService.getUser(1);
  expect(user.name).toBe('John');
});
```

### Time Mocking

```typescript
// Jest fake timers
jest.useFakeTimers();
jest.setSystemTime(new Date('2024-01-15'));

afterEach(() => {
  jest.useRealTimers();
});

it('should use mocked date', () => {
  expect(new Date().toISOString()).toContain('2024-01-15');
});
```

### Environment Variable Mocking

```typescript
const originalEnv = process.env;

beforeEach(() => {
  process.env = { ...originalEnv };
});

afterEach(() => {
  process.env = originalEnv;
});

it('should use env variable', () => {
  process.env.API_KEY = 'test-key';
  expect(config.apiKey).toBe('test-key');
});
```

## Database Mocking

### Prisma Mocking

```typescript
// __mocks__/@prisma/client.ts
import { PrismaClient } from '@prisma/client';
import { mockDeep, DeepMockProxy } from 'jest-mock-extended';

export const prismaMock = mockDeep<PrismaClient>();

// Test
import { prismaMock } from './__mocks__/@prisma/client';

prismaMock.user.findUnique.mockResolvedValue({
  id: '1',
  email: 'test@example.com',
});
```

### Repository Mocking

```typescript
const mockUserRepository = {
  findById: jest.fn(),
  create: jest.fn(),
  update: jest.fn(),
  delete: jest.fn(),
};

// Inject into DI container
container.register('UserRepository', { useValue: mockUserRepository });
```

## Mocking Strategy

### When to Mock

| What to Mock | What NOT to Mock |
|-------------|-----------------|
| External API calls | Code under test |
| Database (unit tests) | Pure functions |
| File system | Value objects |
| Current time | Internal utilities |
| Random values | |

### Mocking Layers

```
┌─────────────────────────────────────┐
│           Controller                │  ← API test: Real request
├─────────────────────────────────────┤
│            Service                  │  ← Service test: Mock Repository
├─────────────────────────────────────┤
│           Repository                │  ← Integration test: Real DB
├─────────────────────────────────────┤
│           Database                  │
└─────────────────────────────────────┘
```

## Spy

```typescript
// Track calls while preserving real implementation
const spy = jest.spyOn(service, 'validate');

await service.process(data);

expect(spy).toHaveBeenCalledWith(data);
spy.mockRestore();
```

## Mock Reset

```typescript
beforeEach(() => {
  jest.clearAllMocks();   // Reset call records only
  // jest.resetAllMocks(); // Also reset implementations
  // jest.restoreAllMocks(); // Restore original implementations
});
```

## Type-Safe Mocking

```typescript
import { mock, MockProxy } from 'jest-mock-extended';

interface UserService {
  getUser(id: string): Promise<User>;
}

const mockService: MockProxy<UserService> = mock<UserService>();
mockService.getUser.mockResolvedValue(user);
```

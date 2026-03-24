# Backend Test Patterns Guide

## Unit Test Patterns

### 1. Dependency Injection Testing

```typescript
// Testable structure
class UserService {
  constructor(
    private userRepository: UserRepository,
    private emailService: EmailService
  ) {}
}

// Test
const mockUserRepo = createMock<UserRepository>();
const mockEmailService = createMock<EmailService>();
const service = new UserService(mockUserRepo, mockEmailService);
```

### 2. Pure Function Testing

```typescript
// utils/validation.ts
export function isValidEmail(email: string): boolean {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email);
}

// Test
describe('isValidEmail', () => {
  it.each([
    ['valid@example.com', true],
    ['invalid', false],
    ['@example.com', false],
  ])('should return %s for %s', (email, expected) => {
    expect(isValidEmail(email)).toBe(expected);
  });
});
```

### 3. Error Case Testing

```typescript
describe('error handling', () => {
  it('should throw specific error', async () => {
    mockRepo.findById.mockRejectedValue(new DatabaseError('Connection failed'));

    await expect(service.getUser('id')).rejects.toThrow(DatabaseError);
  });

  it('should handle and wrap errors', async () => {
    mockRepo.findById.mockRejectedValue(new Error('Unknown'));

    await expect(service.getUser('id')).rejects.toMatchObject({
      code: 'INTERNAL_ERROR',
      message: expect.stringContaining('Unknown'),
    });
  });
});
```

## Integration Test Patterns

### 1. API Testing

```typescript
describe('POST /api/users', () => {
  it('should create user and return 201', async () => {
    const response = await request(app)
      .post('/api/users')
      .set('Authorization', `Bearer ${token}`)
      .send({ email: 'test@example.com', password: 'Test1234!' });

    expect(response.status).toBe(201);
    expect(response.body).toMatchObject({
      data: { email: 'test@example.com' }
    });
  });
});
```

### 2. Database Testing

```typescript
describe('UserRepository', () => {
  beforeEach(async () => {
    await prisma.user.deleteMany();
  });

  it('should create and retrieve user', async () => {
    const created = await userRepo.create({
      email: 'test@example.com',
      password: 'hashed',
    });

    const found = await userRepo.findById(created.id);

    expect(found).toMatchObject({
      email: 'test@example.com',
    });
  });
});
```

### 3. External Service Integration Testing

```typescript
// Real service testing (CI environment only)
describe.skipIf(process.env.CI)('EmailService Integration', () => {
  it('should send email via provider', async () => {
    const result = await emailService.send({
      to: 'test@example.com',
      subject: 'Test',
      body: 'Test body',
    });

    expect(result.messageId).toBeDefined();
  });
});
```

## Test Isolation Patterns

### 1. Transaction Rollback

```typescript
describe('Database tests', () => {
  beforeEach(async () => {
    await prisma.$executeRaw`BEGIN`;
  });

  afterEach(async () => {
    await prisma.$executeRaw`ROLLBACK`;
  });
});
```

### 2. Test Containers

```typescript
// Using docker-compose.test.yml
beforeAll(async () => {
  await exec('docker-compose -f docker-compose.test.yml up -d');
  await waitForDatabase();
});

afterAll(async () => {
  await exec('docker-compose -f docker-compose.test.yml down');
});
```

## Async Test Patterns

### 1. Promise Testing

```typescript
it('should resolve with user', async () => {
  const user = await service.getUser('id');
  expect(user).toBeDefined();
});

it('should reject with error', async () => {
  await expect(service.getUser('invalid')).rejects.toThrow();
});
```

### 2. Event Testing

```typescript
it('should emit event', (done) => {
  emitter.on('userCreated', (user) => {
    expect(user.email).toBe('test@example.com');
    done();
  });

  service.createUser({ email: 'test@example.com' });
});
```

### 3. Timer Testing

```typescript
jest.useFakeTimers();

it('should retry after delay', async () => {
  const promise = service.retryableOperation();

  jest.advanceTimersByTime(1000);

  await expect(promise).resolves.toBeDefined();
});
```

## Test Data Patterns

### 1. Builder Pattern

```typescript
class UserBuilder {
  private user = {
    email: 'default@example.com',
    password: 'Test1234!',
    role: 'user',
  };

  withEmail(email: string) {
    this.user.email = email;
    return this;
  }

  withRole(role: string) {
    this.user.role = role;
    return this;
  }

  build() {
    return { ...this.user };
  }
}

// Usage
const admin = new UserBuilder().withRole('admin').build();
```

### 2. Mother Pattern

```typescript
class UserMother {
  static valid() {
    return {
      email: 'test@example.com',
      password: 'Test1234!',
    };
  }

  static withInvalidEmail() {
    return {
      ...this.valid(),
      email: 'invalid',
    };
  }

  static admin() {
    return {
      ...this.valid(),
      role: 'admin',
    };
  }
}
```

## Performance Test Patterns

```typescript
describe('Performance', () => {
  it('should respond within 100ms', async () => {
    const start = performance.now();

    await service.heavyOperation();

    const duration = performance.now() - start;
    expect(duration).toBeLessThan(100);
  });
});
```

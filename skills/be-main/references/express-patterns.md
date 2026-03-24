# Express Best Practices (TypeScript)

> Patterns and conventions for Express backend projects.
> See also: [architecture-guide.md](architecture-guide.md), [security-guide.md](security-guide.md)

## Project Structure

```
src/
├── app.ts                       # Express app setup
├── server.ts                    # HTTP server bootstrap
├── config/
│   └── index.ts                 # Environment config
├── routes/
│   ├── index.ts                 # Route aggregator
│   ├── auth.routes.ts
│   └── users.routes.ts
├── controllers/
│   ├── auth.controller.ts
│   └── users.controller.ts
├── services/
│   ├── auth.service.ts
│   └── users.service.ts
├── repositories/
│   └── users.repository.ts
├── middlewares/
│   ├── auth.middleware.ts
│   ├── error.middleware.ts
│   └── validation.middleware.ts
├── dtos/
│   ├── requests/
│   │   └── create-user.dto.ts
│   └── responses/
│       └── user.response.ts
├── errors/
│   ├── base.error.ts
│   ├── not-found.error.ts
│   └── validation.error.ts
├── schemas/
│   └── auth.schema.ts           # Zod / Joi schemas
├── prisma/
│   └── client.ts                # Prisma client singleton
└── utils/
    └── crypto.ts
```

## Router-Based Architecture

```typescript
// routes/auth.routes.ts
import { Router } from 'express';
import { AuthController } from '@/controllers/auth.controller';

export function authRoutes(controller: AuthController): Router {
  const router = Router();
  router.post('/signup', controller.signup);
  router.post('/login', controller.login);
  return router;
}

// routes/index.ts
export function setupRoutes(app: Express, deps: Dependencies) {
  app.use('/auth', authRoutes(deps.authController));
  app.use('/users', authMiddleware, usersRoutes(deps.usersController));
}
```

## Middleware Chains

```typescript
// app.ts
const app = express();

// Global middleware — order matters
app.use(helmet());
app.use(cors(corsOptions));
app.use(express.json({ limit: '10mb' }));
app.use(requestLogger);

// Routes
setupRoutes(app, dependencies);

// Error handler must be last
app.use(errorHandler);
```

## Error Handling Middleware

```typescript
// errors/base.error.ts
export abstract class AppError extends Error {
  abstract statusCode: number;
  abstract code: string;
  constructor(message: string) {
    super(message);
    this.name = this.constructor.name;
  }
}

// middlewares/error.middleware.ts
export function errorHandler(
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction,
) {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      error: { code: err.code, message: err.message },
    });
  }
  console.error(err);
  res.status(500).json({
    error: { code: 'INTERNAL_ERROR', message: 'A server error occurred.' },
  });
}
```

- Always pass errors to `next(error)` in async handlers.
- Use an async wrapper to catch promise rejections:

```typescript
export const asyncHandler =
  (fn: RequestHandler): RequestHandler =>
  (req, res, next) =>
    Promise.resolve(fn(req, res, next)).catch(next);
```

## Service Layer with Manual DI

```typescript
// Composition root — wire dependencies manually
// container.ts
const prisma = new PrismaClient();
const usersRepository = new UsersRepository(prisma);
const usersService = new UsersService(usersRepository);
const usersController = new UsersController(usersService);

export const dependencies = { usersController, authController };
```

For larger projects, use **tsyringe** or **inversify**:

```typescript
// tsyringe example
@injectable()
export class UsersService {
  constructor(@inject('UsersRepository') private repo: UsersRepository) {}
}
```

## Validation with Zod

```typescript
// schemas/auth.schema.ts
import { z } from 'zod';

export const signupSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

// middlewares/validation.middleware.ts
export function validate(schema: z.ZodSchema) {
  return (req: Request, _res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      throw new ValidationError(
        result.error.errors.map((e) => ({
          field: e.path.join('.'),
          message: e.message,
        })),
      );
    }
    req.body = result.data;
    next();
  };
}
```

## Prisma Integration

```typescript
// prisma/client.ts
import { PrismaClient } from '@prisma/client';
export const prisma = new PrismaClient();

// repositories/users.repository.ts
export class UsersRepository {
  constructor(private prisma: PrismaClient) {}

  findByEmail(email: string) {
    return this.prisma.user.findUnique({ where: { email } });
  }

  create(data: { id: string; email: string; password: string }) {
    return this.prisma.user.create({ data });
  }
}
```

## TypeORM Integration

```typescript
import { DataSource } from 'typeorm';

export const AppDataSource = new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  entities: ['src/entities/**/*.ts'],
  migrations: ['src/migrations/**/*.ts'],
});

// Repository usage
const userRepo = AppDataSource.getRepository(User);
const user = await userRepo.findOneBy({ email });
```

## Testing with Supertest + Jest

```typescript
// tests/auth.test.ts
import request from 'supertest';
import { createApp } from '@/app';

describe('POST /auth/signup', () => {
  let app: Express;

  beforeAll(() => {
    app = createApp(testDependencies);
  });

  it('should return 201 for valid signup', async () => {
    const res = await request(app)
      .post('/auth/signup')
      .send({ email: 'test@example.com', password: 'StrongP@ss1' });

    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('id');
  });

  it('should return 400 for invalid email', async () => {
    const res = await request(app)
      .post('/auth/signup')
      .send({ email: 'invalid', password: 'StrongP@ss1' });

    expect(res.status).toBe(400);
  });
});
```

- Export `createApp()` separately from `server.ts` so tests can import it without starting the server.
- Use a test database or mock the repository layer.
- Reset state between tests with `beforeEach` / `afterEach`.

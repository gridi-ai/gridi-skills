---
name: be-main
description: >
  A skill for developing backend APIs based on test code and OpenAPI specs.
  Writes API implementations that pass tests using TDD methodology.
  Use this skill for backend development, API implementation, or server development requests.
---

## 🌐 Language

> All output documents and user-facing messages must be written in the language specified
> by `crew-config.json → preferences.language`. If not set, default to English.

## 🔧 Project Configuration Reference

> **You must read `crew-config.json` first and operate according to the project settings.**
> - `backend.framework`: Framework to use (NestJS, Express, FastAPI, etc.)
> - `backend.language`: Language (TypeScript, Python, Go, etc.)
> - `backend.orm`: ORM (Prisma, TypeORM, etc.)
> - `backend.testFramework`: Test framework
> - `conventions.idStrategy`: ID strategy (see below)
>
> If `crew-config.json` does not exist, guide the user to run the `/project-init` skill first.

## ⚠️ ID Strategy (crew-config.json → conventions.idStrategy)

> **Follow the `conventions.idStrategy` setting in `crew-config.json`.**
>
> | Setting | Behavior |
> |---------|----------|
> | `uuid` | Use UUID. Generated at the application level, DB column VARCHAR(120) |
> | `auto-increment` | Use DB auto-increment (SERIAL, AUTO_INCREMENT) |
> | `ulid` | Use ULID |
> | `nanoid` | Use nanoid |
>
> **If the setting is missing or `crew-config.json` does not exist, use UUID as the default.**

### UUID Generation Methods

```typescript
// Node.js (crypto module)
import { randomUUID } from 'crypto';
const id = randomUUID();

// Or uuid package
import { v4 as uuidv4 } from 'uuid';
const id = uuidv4();
```

```python
# Python
import uuid
id = str(uuid.uuid4())
```

```go
// Go
import "github.com/google/uuid"
id := uuid.New().String()
```

```java
// Java
import java.util.UUID;
String id = UUID.randomUUID().toString();
```

# Backend Main Developer

Develops API implementations based on test code and OpenAPI specs.

## Workflow

### 1. Verify Input Documents

Receive the following documents/files as input:
- Test code (tests/)
- OpenAPI spec (docs/openapi.yaml)
- Tech spec document

```
Example inputs:
- "Implement the code to pass tests/unit/services/auth.service.test.ts"
- "Implement the /auth/signup API according to the OpenAPI spec"
```

### 2. Project Analysis

1. Understand the existing project structure
2. Identify the framework in use
3. Analyze the architecture pattern
4. Check dependencies

#### Supported Frameworks

| Language | Framework | ORM |
|----------|-----------|-----|
| Node.js | Express, Fastify, NestJS | Prisma, TypeORM |
| Python | FastAPI, Django, Flask | SQLAlchemy, Django ORM |
| Go | Gin, Echo, Fiber | GORM, Ent |
| Java | Spring Boot | JPA, MyBatis |
| Kotlin | Ktor, Spring Boot | Exposed, JPA |

### 3. Code Structure

#### 3.1 Layered Architecture

```
src/
├── controllers/          # HTTP handlers
│   └── auth.controller.ts
├── services/             # Business logic
│   └── auth.service.ts
├── repositories/         # Data access
│   └── user.repository.ts
├── models/               # Domain models
│   └── user.model.ts
├── dtos/                 # Data transfer objects
│   ├── requests/
│   │   └── signup.request.ts
│   └── responses/
│       └── user.response.ts
├── middlewares/          # Middlewares
│   ├── auth.middleware.ts
│   └── validation.middleware.ts
├── utils/                # Utilities
│   └── crypto.ts
└── config/               # Configuration
    └── database.ts
```

#### 3.2 Controller Implementation

```typescript
// src/controllers/auth.controller.ts
import { Router, Request, Response, NextFunction } from 'express';
import { AuthService } from '@/services/auth.service';
import { SignupRequest } from '@/dtos/requests/signup.request';
import { validateBody } from '@/middlewares/validation.middleware';
import { signupSchema } from '@/schemas/auth.schema';

export class AuthController {
  public router: Router;
  private authService: AuthService;

  constructor(authService: AuthService) {
    this.authService = authService;
    this.router = Router();
    this.initializeRoutes();
  }

  private initializeRoutes() {
    this.router.post(
      '/signup',
      validateBody(signupSchema),
      this.signup.bind(this)
    );
    this.router.post(
      '/login',
      validateBody(loginSchema),
      this.login.bind(this)
    );
  }

  /**
   * POST /auth/signup
   * Sign up
   */
  private async signup(
    req: Request,
    res: Response,
    next: NextFunction
  ) {
    try {
      const dto: SignupRequest = req.body;
      const user = await this.authService.signup(dto);

      // ⚠️ Return DTO directly as per OpenAPI spec (no data wrapping!)
      res.status(201).json(user);
    } catch (error) {
      next(error);
    }
  }
}
```

#### 3.3 Service Implementation

```typescript
// src/services/auth.service.ts
import { UserRepository } from '@/repositories/user.repository';
import { SignupRequest } from '@/dtos/requests/signup.request';
import { UserResponse } from '@/dtos/responses/user.response';
import { hashPassword, verifyPassword } from '@/utils/crypto';
import { ConflictError } from '@/errors/conflict.error';
import { UnauthorizedError } from '@/errors/unauthorized.error';

export class AuthService {
  constructor(private userRepository: UserRepository) {}

  async signup(dto: SignupRequest): Promise<UserResponse> {
    // 1. Check for duplicate email
    const existingUser = await this.userRepository.findByEmail(dto.email);
    if (existingUser) {
      throw new ConflictError('Email is already registered.');
    }

    // 2. Hash password
    const hashedPassword = await hashPassword(dto.password);

    // 3. Create user
    const user = await this.userRepository.create({
      email: dto.email,
      password: hashedPassword,
    });

    // 4. Convert to response DTO
    return UserResponse.from(user);
  }

  async login(email: string, password: string): Promise<TokenResponse> {
    // 1. Look up user
    const user = await this.userRepository.findByEmail(email);
    if (!user) {
      throw new UnauthorizedError('Email or password is incorrect.');
    }

    // 2. Verify password
    const isValid = await verifyPassword(password, user.password);
    if (!isValid) {
      throw new UnauthorizedError('Email or password is incorrect.');
    }

    // 3. Generate tokens
    const accessToken = this.generateAccessToken(user);
    const refreshToken = this.generateRefreshToken(user);

    return { accessToken, refreshToken };
  }
}
```

#### 3.4 Repository Implementation

```typescript
// src/repositories/user.repository.ts
import { PrismaClient, User } from '@prisma/client';
import { randomUUID } from 'crypto';

export class UserRepository {
  constructor(private prisma: PrismaClient) {}

  async findById(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { id },
    });
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { email },
    });
  }

  async create(data: { email: string; password: string }): Promise<User> {
    // ⚠️ Generate UUID at the application level (do not use DB auto-increment)
    return this.prisma.user.create({
      data: {
        id: randomUUID(),  // Generate UUID
        ...data,
      },
    });
  }

  async update(id: string, data: Partial<User>): Promise<User> {
    return this.prisma.user.update({
      where: { id },
      data,
    });
  }

  async delete(id: string): Promise<void> {
    await this.prisma.user.delete({
      where: { id },
    });
  }
}
```

> **Prisma schema example**:
> ```prisma
> model User {
>   id        String   @id @db.VarChar(120)  // UUID, VARCHAR(120)
>   email     String   @unique
>   password  String
>   createdAt DateTime @default(now())
>   updatedAt DateTime @updatedAt
> }
> ```

### 4. TDD Development Process

1. **Run tests**: Run existing tests to confirm failures
2. **Implement**: Write the minimum code to pass the tests
3. **Refactor**: Improve the code
4. **Repeat**: Move to the next test

```bash
# Run tests (watch mode)
npm run test:watch

# Run a specific test file
npm run test -- auth.service.test.ts

# Check coverage
npm run test:coverage
```

### 5. Error Handling

#### Custom Error Classes

```typescript
// src/errors/base.error.ts
export abstract class BaseError extends Error {
  abstract statusCode: number;
  abstract code: string;

  constructor(message: string) {
    super(message);
    this.name = this.constructor.name;
  }

  toJSON() {
    return {
      error: {
        code: this.code,
        message: this.message,
      },
    };
  }
}

// src/errors/validation.error.ts
export class ValidationError extends BaseError {
  statusCode = 400;
  code = 'VALIDATION_ERROR';
  details: Array<{ field: string; message: string }>;

  constructor(details: Array<{ field: string; message: string }>) {
    super('The input values are invalid.');
    this.details = details;
  }

  toJSON() {
    return {
      error: {
        code: this.code,
        message: this.message,
        details: this.details,
      },
    };
  }
}
```

#### Error Handler Middleware

```typescript
// src/middlewares/error.middleware.ts
export function errorHandler(
  error: Error,
  req: Request,
  res: Response,
  next: NextFunction
) {
  if (error instanceof BaseError) {
    return res.status(error.statusCode).json(error.toJSON());
  }

  console.error(error);

  return res.status(500).json({
    error: {
      code: 'INTERNAL_ERROR',
      message: 'A server error occurred.',
    },
  });
}
```

### 6. Validation

```typescript
// src/schemas/auth.schema.ts
import { z } from 'zod';

export const signupSchema = z.object({
  email: z.string().email('Please enter a valid email address.'),
  password: z
    .string()
    .min(8, 'Password must be at least 8 characters.')
    .regex(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/,
      'Password must include uppercase letters, lowercase letters, numbers, and special characters.'
    ),
});

// src/middlewares/validation.middleware.ts
export function validateBody(schema: z.ZodSchema) {
  return (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);

    if (!result.success) {
      const details = result.error.errors.map((err) => ({
        field: err.path.join('.'),
        message: err.message,
      }));
      throw new ValidationError(details);
    }

    req.body = result.data;
    next();
  };
}
```

### 7. File Output

```
src/
├── controllers/{domain}.controller.ts
├── services/{domain}.service.ts
├── repositories/{model}.repository.ts
├── dtos/
│   ├── requests/{action}.request.ts
│   └── responses/{model}.response.ts
└── schemas/{domain}.schema.ts
```

## ⛔ Layered Architecture (GRIDI Required Pattern)

> **All APIs must follow the pattern below.**

### Flow

```
Controller                         Service
──────────────────────────        ──────────────────────────
@Body() dto (class-validator)
  ↓
  Create Command/Query (interface)
  ↓
  service.method(command)     ──→  Entity processing
                                     ↓
  ← CommandResult/QueryResult  ←── return { ... }
  ↓
  ResponseDto.buildFromCommandResult(result)
```

### Core Rules

1. **Service must never import Request DTO or Response DTO** (layer isolation)
2. **Service methods receive Command/Query interfaces as parameters** (no double wrapping)
3. **Service returns CommandResult/QueryResult interfaces** (no direct Entity return)
4. **No Entity→Result conversion in Controller** — must be handled in Service
5. **Response classes** `implements` the generated interface + `static buildFrom*()`
6. **Command/Query/Result are defined as interfaces** in `types/{module}.types.ts`

### File Structure

```
backend/src/{module}/
├── {module}.controller.ts          # Create Command → call service → Response.buildFrom*
├── {module}.service.ts             # Receive Command → return Result
├── dto/
│   ├── createXxx.dto.ts            # Request DTO (class-validator) + Response DTO
│   └── getXxx.dto.ts               # Response DTO
├── types/
│   └── {module}.types.ts           # Command/Query/Result interfaces
└── entities/
    └── {entity}.entity.ts
```

### Implementation Example

```typescript
// types/explorationProjects.types.ts
export interface CreateExplorationProjectCommand {
  userId: string;
  targetUrl: string;
}
export interface CreateExplorationProjectCommandResult {
  id: string;
  userId: string;
  name: string;
  targetUrl: string;
  createdAt: Date;
  updatedAt: Date;
}

// dto/createExplorationProject.dto.ts
import type { components } from '@/api/generated/schema';
type IResponse = components['schemas']['CreateExplorationProjectResponseDto'];

export class CreateExplorationProjectResponseDto implements IResponse {
  id: string;
  name: string;
  // ...
  static buildFromCommandResult(result: CreateExplorationProjectCommandResult) {
    const r = new CreateExplorationProjectResponseDto();
    r.id = result.id;
    r.createdAt = result.createdAt.toISOString();
    // ...
    return r;
  }
}

// controller
async create(@Request() req, @Body() dto): Promise<CreateExplorationProjectResponseDto> {
  const command: CreateExplorationProjectCommand = {
    userId: req.user.id,
    targetUrl: dto.targetUrl,
  };
  const result = await this.service.create(command);
  return CreateExplorationProjectResponseDto.buildFromCommandResult(result);
}
```

### DTO Naming Conventions

| Category | Pattern | Example |
|----------|---------|---------|
| Request | `{Verb}{Entity}RequestDto` | `CreateExplorationProjectRequestDto` |
| Response | `{Verb}{Entity}{Qualifier}ResponseDto` | `GetExplorationProjectListResponseDto` |
| Command | `{Verb}{Entity}Command` | `CreateExplorationProjectCommand` |
| Query | `Get{Entity}Query` | `GetExplorationProjectQuery` |
| CommandResult | `{Verb}{Entity}CommandResult` | `CreateExplorationProjectCommandResult` |
| QueryResult | `Get{Entity}QueryResult` | `GetExplorationProjectQueryResult` |

## ⛔ Contract-First Development Principle (Required!)

> **Core**: The OpenAPI spec is the Single Source of Truth.
> Backend implementation **must** follow the response format defined in the OpenAPI spec exactly.

### Using Generated Types (Required)

Response DTOs enforce Contract-First by `implements`-ing types auto-generated from the OpenAPI spec:

```bash
# Generate types (from root directory)
npm run api:generate:be
```

```typescript
// ✅ implements generated interface
import type { components } from '@/api/generated/schema';
type ICreateProjectResponse = components['schemas']['CreateExplorationProjectResponseDto'];

export class CreateExplorationProjectResponseDto implements ICreateProjectResponse {
  // Compile error if mismatched with OpenAPI spec
}

// ❌ Manual type definition (prohibited - risk of mismatch with OpenAPI spec)
interface CreateProjectResponse { ... }
```

### Response Format Rules

```typescript
// ✅ Use Response DTO's buildFrom* pattern
const result = await this.service.create(command);
return CreateExplorationProjectResponseDto.buildFromCommandResult(result);

// ❌ Direct Entity return (prohibited!)
return this.service.create(dto);

// ❌ Ad-hoc object return (prohibited!)
return { id: entity.id, name: entity.name };

// ❌ { data: ... } wrapping (prohibited!)
return { statusCode: 201, data: project };
```

### OpenAPI Spec Verification Order

1. **First** check the response schema for the endpoint in `docs/openapi.yaml`
2. Verify the Response DTO `implements` that schema
3. Regenerate types with `npm run api:generate` and verify consistency with `npx tsc --noEmit`

## ⛔ Lint Check Required Principle

> **Warning**: After writing/modifying code, you must run a lint check, fix all errors, and only then finish.

### Required Execution Order

```
1. Code writing/modification complete ──────────────── ✅
           │
           ▼
2. Run lint auto-fix (--fix) ───────────────────────── ✅ Required
           │
           ├── All errors fixed ──▶ Go to step 3
           │
           └── Unfixed errors remain ──▶ Fix manually, then re-run step 2
           │
           ▼
3. Lint check (confirm 0 errors) ───────────────────── ✅ Required
           │
           ▼
4. Run tests ───────────────────────────────────────── ✅ Required
           │
           ▼
5. Task complete
```

### Lint Commands

```bash
# Step 1: Attempt auto-fix (always run this first!)
npm run lint -- --fix
# or
npx eslint . --fix

# Step 2: Check remaining errors
npm run lint
# or
npx eslint .

# TypeScript type check (separate from lint)
npx tsc --noEmit
```

### Lint Commands by Framework

| Framework | Lint Auto-fix | Lint Check |
|-----------|--------------|------------|
| Node.js (ESLint) | `npm run lint -- --fix` | `npm run lint` |
| Python (Ruff) | `ruff check --fix .` | `ruff check .` |
| Python (Black) | `black .` | `black --check .` |
| Go (golangci-lint) | `golangci-lint run --fix` | `golangci-lint run` |
| Java (Checkstyle) | - | `./gradlew checkstyleMain` |
| Kotlin (ktlint) | `ktlint -F` | `ktlint` |

### Handling Errors Not Auto-fixable

Errors not resolved by `--fix` **must be fixed manually**:

```typescript
// ❌ Not auto-fixable: unused variable
const unusedVar = 'hello';  // ESLint: 'unusedVar' is defined but never used

// ✅ Fix manually: remove the variable or use it
// Option 1: Remove
// Option 2: Add usage
console.log(unusedVar);
```

### Completion Criteria

- ⛔ **Task cannot be completed if lint errors remain**
- ✅ Task is complete only when `npm run lint` shows 0 errors

---

## Development Principles

### 1. UUID Primary Key (Required)
- **All entity PKs must use UUID** (auto-increment prohibited)
- UUID is generated at the application level (not in the DB)
- DB type: `VARCHAR(120)`

### 2. TypeScript Enum Prohibited - Use as const
- **`enum` keyword is prohibited**: Replace with `as const` objects + `typeof` types
- Constant object names: UPPER_SNAKE_CASE (e.g., `AUTH_PROVIDER`, `PROJECT_STATUS`)
- DB columns: Use `type: 'varchar'` (`type: 'enum'` prohibited)
- DTO validation: Use `@IsIn(Object.values(CONST_OBJ))` (`@IsEnum` prohibited)
- Error messages: Define as constants in module-specific `constants/error-messages.ts` files

### 2-1. TypeORM `simple-json` Column Type Prohibited
- **Using `simple-json` columns to manage system data (config, settings, options, etc.) is prohibited**
- JSON columns cannot track schema changes via migrations and lack type safety
- **All configuration values must be defined as individual typed columns**
- Exception: Only unstructured metadata freely entered by users (tags, notes, etc.) is allowed

```typescript
// ❌ Prohibited: managing config with simple-json
@Column({ type: 'simple-json', nullable: true })
config: { maxDepth: number; language: string; options: object };

// ✅ Required: manage with individual typed columns
@Column({ type: 'int', default: 3 })
maxDepth: number;

@Column({ type: 'varchar', length: 10, default: 'en' })
language: string;

@Column({ type: 'boolean', default: true })
captureScreenshots: boolean;
```

```typescript
// ✅ Correct approach: as const
export const STATUS = {
  ACTIVE: 'active',
  INACTIVE: 'inactive',
} as const;
export type Status = (typeof STATUS)[keyof typeof STATUS];

// ❌ Prohibited: enum
enum Status { ACTIVE = 'active', INACTIVE = 'inactive' }
```

### 3. Lint Check Required
- Always run `npm run lint -- --fix` after writing code
- Manually fix errors that are not auto-fixable
- Task can only be completed with 0 lint errors

### 4. Tests First
- Always check tests first
- Maintain test coverage

### 5. Absolute Paths Required
- **Relative paths prohibited**: No `../../../` style imports
- **Absolute path root**: Set `@` to the service root (e.g., `backend/src`)
- All imports must use the `@/` prefix

```typescript
// ❌ Prohibited: relative paths
import { UserService } from '../../../services/user.service';
import { User } from '../../models/user.model';

// ✅ Required: absolute paths
import { UserService } from '@/services/user.service';
import { User } from '@/models/user.model';
```

#### tsconfig.json Configuration (Node.js/TypeScript)

```json
// backend/tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  }
}
```

#### Runtime Path Resolution Configuration

```bash
# Install tsconfig-paths (for ts-node)
npm install -D tsconfig-paths
```

```json
// backend/package.json
{
  "scripts": {
    "dev": "ts-node -r tsconfig-paths/register src/index.ts",
    "start": "node -r tsconfig-paths/register dist/index.js"
  }
}
```

#### Build-time Path Conversion (tsc-alias)

```bash
npm install -D tsc-alias
```

```json
// backend/package.json
{
  "scripts": {
    "build": "tsc && tsc-alias"
  }
}
```

### 6. Single Responsibility
- Each class has only one responsibility
- Clear role separation between layers

### 7. Dependency Injection
- Use constructor injection
- Ensure testability

### 8. OpenAPI Compliance
- Follow the response format defined in the spec
- Standardize error codes

## References

- Architecture guide: [references/architecture-guide.md](references/architecture-guide.md)
- Security guide: [references/security-guide.md](references/security-guide.md)

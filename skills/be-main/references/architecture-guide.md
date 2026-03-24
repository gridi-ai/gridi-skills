# Backend Architecture Guide

> **Note**: Examples shown for NestJS/TypeScript. Apply equivalent patterns for your framework.
> See `crew-config.json → backend.framework` for your project's framework.

## Layered Architecture

```
┌─────────────────────────────────────┐
│          Presentation Layer          │ ← Controllers, Middlewares
├─────────────────────────────────────┤
│          Application Layer           │ ← Services, Use Cases
├─────────────────────────────────────┤
│           Domain Layer               │ ← Models, Business Rules
├─────────────────────────────────────┤
│        Infrastructure Layer          │ ← Repositories, External APIs
└─────────────────────────────────────┘
```

## Role of Each Layer

### Presentation Layer

- Handle HTTP requests/responses
- Input validation
- Authentication/authorization middleware
- DTO conversion

```typescript
// Controller - HTTP concerns only
@Controller('/users')
export class UserController {
  constructor(private userService: UserService) {}

  @Post()
  async create(@Body() dto: CreateUserDto) {
    return this.userService.createUser(dto);
  }
}
```

### Application Layer

- Orchestrate business use cases
- Transaction management
- Domain object composition

```typescript
// Service - Business logic
export class UserService {
  constructor(
    private userRepo: UserRepository,
    private emailService: EmailService
  ) {}

  async createUser(dto: CreateUserDto): Promise<User> {
    const user = await this.userRepo.create(dto);
    await this.emailService.sendWelcome(user.email);
    return user;
  }
}
```

### Domain Layer

- Core business rules
- Entities, value objects
- Domain events

```typescript
// Entity - Contains business rules
export class User {
  private constructor(
    readonly id: string,
    private _email: string,
    private _status: UserStatus
  ) {}

  activate(): void {
    if (this._status !== UserStatus.PENDING) {
      throw new Error('Cannot activate non-pending user');
    }
    this._status = UserStatus.ACTIVE;
  }
}
```

### Infrastructure Layer

- Database access
- External API communication
- File system

```typescript
// Repository - Data access
export class UserRepository {
  constructor(private prisma: PrismaClient) {}

  async findById(id: string): Promise<User | null> {
    const data = await this.prisma.user.findUnique({ where: { id } });
    return data ? User.fromData(data) : null;
  }
}
```

## Dependency Rules

```
Presentation → Application → Domain ← Infrastructure
                               ↑
                      (Dependency Inversion)
```

- Inner layers must not know about outer layers
- Domain does not depend on Infrastructure
- Dependency inversion through interfaces

```typescript
// Domain Layer - Interface
export interface IUserRepository {
  findById(id: string): Promise<User | null>;
  save(user: User): Promise<void>;
}

// Infrastructure Layer - Implementation
export class PrismaUserRepository implements IUserRepository {
  // ...
}

// Application Layer - Depends on interface
export class UserService {
  constructor(private userRepo: IUserRepository) {}
}
```

## Directory Structure

### Feature-based

```
src/
├── features/
│   ├── auth/
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   ├── auth.repository.ts
│   │   └── auth.schema.ts
│   └── users/
│       ├── users.controller.ts
│       ├── users.service.ts
│       └── users.repository.ts
└── shared/
    ├── middlewares/
    └── utils/
```

### Layer-based

```
src/
├── controllers/
│   ├── auth.controller.ts
│   └── users.controller.ts
├── services/
│   ├── auth.service.ts
│   └── users.service.ts
├── repositories/
│   ├── auth.repository.ts
│   └── users.repository.ts
└── models/
    └── user.model.ts
```

## Module Composition (NestJS Example)

```typescript
@Module({
  imports: [
    DatabaseModule,
    ConfigModule,
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    {
      provide: 'IUserRepository',
      useClass: PrismaUserRepository,
    },
  ],
  exports: [AuthService],
})
export class AuthModule {}
```

## Transaction Handling

```typescript
// Manage transactions at the service layer
export class OrderService {
  async createOrder(dto: CreateOrderDto): Promise<Order> {
    return this.prisma.$transaction(async (tx) => {
      // 1. Check and decrease inventory
      await this.inventoryRepo.decrease(tx, dto.productId, dto.quantity);

      // 2. Create order
      const order = await this.orderRepo.create(tx, dto);

      // 3. Process payment
      await this.paymentService.process(tx, order);

      return order;
    });
  }
}
```

## CQRS Pattern (Optional)

```
┌─────────────────────────────────────┐
│              Commands               │ → Write Model → Database
├─────────────────────────────────────┤
│              Queries                │ → Read Model → Database/Cache
└─────────────────────────────────────┘
```

```typescript
// Command
export class CreateUserCommand {
  constructor(
    public readonly email: string,
    public readonly password: string
  ) {}
}

// Query
export class GetUserQuery {
  constructor(public readonly userId: string) {}
}

// Handler
export class CreateUserHandler {
  async execute(command: CreateUserCommand): Promise<void> {
    // Write logic
  }
}
```

## Event-Driven Architecture

```typescript
// Domain event
export class UserCreatedEvent {
  constructor(
    public readonly userId: string,
    public readonly email: string,
    public readonly createdAt: Date
  ) {}
}

// Event publishing
class UserService {
  async createUser(dto: CreateUserDto): Promise<User> {
    const user = await this.userRepo.create(dto);

    this.eventEmitter.emit(
      'user.created',
      new UserCreatedEvent(user.id, user.email, new Date())
    );

    return user;
  }
}

// Event handler
@OnEvent('user.created')
async handleUserCreated(event: UserCreatedEvent) {
  await this.emailService.sendWelcome(event.email);
  await this.analyticsService.trackSignup(event.userId);
}
```

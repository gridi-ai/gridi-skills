# NestJS Best Practices (TypeScript)

> Patterns and conventions for NestJS backend projects.
> See also: [architecture-guide.md](architecture-guide.md), [security-guide.md](security-guide.md)

## Project Structure

```
src/
├── app.module.ts                # Root module
├── main.ts                      # Bootstrap
├── common/
│   ├── decorators/              # Custom decorators
│   ├── filters/                 # Exception filters
│   ├── guards/                  # Auth guards
│   ├── interceptors/            # Logging, transform interceptors
│   └── pipes/                   # Validation pipes
├── config/
│   └── config.module.ts         # ConfigModule setup
├── auth/
│   ├── auth.module.ts
│   ├── auth.controller.ts
│   ├── auth.service.ts
│   ├── strategies/              # Passport strategies
│   ├── guards/
│   │   └── jwt-auth.guard.ts
│   └── dto/
│       ├── login.dto.ts
│       └── signup.dto.ts
├── users/
│   ├── users.module.ts
│   ├── users.controller.ts
│   ├── users.service.ts
│   ├── users.repository.ts
│   ├── entities/
│   │   └── user.entity.ts
│   └── dto/
│       ├── create-user.dto.ts
│       └── update-user.dto.ts
└── prisma/                      # or typeorm/
    ├── prisma.module.ts
    └── prisma.service.ts
```

## Module / Controller / Service / Repository Pattern

```typescript
// users.module.ts
@Module({
  imports: [PrismaModule],
  controllers: [UsersController],
  providers: [UsersService, UsersRepository],
  exports: [UsersService],
})
export class UsersModule {}
```

Each feature gets its own module. Controllers handle HTTP, services hold business logic, repositories abstract data access.

## Dependency Injection

```typescript
@Injectable()
export class UsersService {
  constructor(
    private readonly usersRepository: UsersRepository,
    private readonly configService: ConfigService,
  ) {}
}
```

- Always use constructor injection.
- Mark providers with `@Injectable()`.
- Use `@Inject()` with tokens for non-class providers.
- Prefer custom providers (`useFactory`, `useValue`) for external libraries.

## Guards

```typescript
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  canActivate(context: ExecutionContext) {
    return super.canActivate(context);
  }
}

// Apply to controller or route
@UseGuards(JwtAuthGuard)
@Get('profile')
getProfile(@Req() req: Request) {
  return req.user;
}
```

- Use guards for authentication and role-based access.
- Apply globally in `main.ts` or per-route with `@UseGuards()`.

## Interceptors

```typescript
@Injectable()
export class TransformInterceptor<T> implements NestInterceptor<T, Response<T>> {
  intercept(context: ExecutionContext, next: CallHandler): Observable<Response<T>> {
    return next.handle().pipe(
      map((data) => ({ success: true, data })),
    );
  }
}
```

- Use interceptors for response transformation, logging, and caching.

## Pipes

```typescript
// Global validation pipe in main.ts
app.useGlobalPipes(
  new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }),
);

// DTO with class-validator
export class CreateUserDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8)
  password: string;
}
```

## Exception Filters

```typescript
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    const status =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;

    const message =
      exception instanceof HttpException
        ? exception.getResponse()
        : { code: 'INTERNAL_ERROR', message: 'A server error occurred.' };

    response.status(status).json({
      error: typeof message === 'string' ? { message } : message,
    });
  }
}
```

- Register globally: `app.useGlobalFilters(new AllExceptionsFilter())`.
- Throw built-in exceptions: `throw new NotFoundException('User not found')`.

## TypeORM Integration

```typescript
// user.entity.ts
@Entity()
export class User {
  @PrimaryColumn({ type: 'varchar', length: 120 })
  id: string;

  @Column({ unique: true })
  email: string;

  @CreateDateColumn()
  createdAt: Date;
}

// users.module.ts
@Module({
  imports: [TypeOrmModule.forFeature([User])],
  providers: [UsersService],
})
export class UsersModule {}

// users.service.ts
constructor(
  @InjectRepository(User)
  private readonly userRepo: Repository<User>,
) {}
```

## Prisma Integration

```typescript
// prisma.service.ts
@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  async onModuleInit() {
    await this.$connect();
  }
}

// users.repository.ts
@Injectable()
export class UsersRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findByEmail(email: string) {
    return this.prisma.user.findUnique({ where: { email } });
  }
}
```

## Testing

```typescript
// users.service.spec.ts
describe('UsersService', () => {
  let service: UsersService;
  let repository: jest.Mocked<UsersRepository>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: UsersRepository,
          useValue: {
            findByEmail: jest.fn(),
            create: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get(UsersService);
    repository = module.get(UsersRepository);
  });

  it('should create a user', async () => {
    repository.create.mockResolvedValue(mockUser);
    const result = await service.create(createUserDto);
    expect(result).toEqual(expect.objectContaining({ email: 'test@example.com' }));
  });
});
```

- Use `@nestjs/testing` `Test.createTestingModule` for unit tests.
- Mock dependencies by providing `useValue` or `useFactory`.
- For e2e tests, use `supertest` with `INestApplication`.

```typescript
// e2e test
let app: INestApplication;
beforeAll(async () => {
  const moduleFixture = await Test.createTestingModule({
    imports: [AppModule],
  }).compile();
  app = moduleFixture.createNestApplication();
  await app.init();
});

it('/users (GET)', () => {
  return request(app.getHttpServer()).get('/users').expect(200);
});
```

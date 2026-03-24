# Spring Boot Best Practices (Java/Kotlin)

> Patterns and conventions for Spring Boot backend projects.
> See also: [architecture-guide.md](architecture-guide.md), [security-guide.md](security-guide.md)

## Project Structure

```
src/
├── main/
│   ├── java/com/example/app/
│   │   ├── Application.java            # @SpringBootApplication
│   │   ├── config/
│   │   │   ├── SecurityConfig.java
│   │   │   ├── WebConfig.java
│   │   │   └── SwaggerConfig.java
│   │   ├── auth/
│   │   │   ├── AuthController.java
│   │   │   ├── AuthService.java
│   │   │   ├── dto/
│   │   │   │   ├── LoginRequest.java
│   │   │   │   └── TokenResponse.java
│   │   │   └── security/
│   │   │       ├── JwtFilter.java
│   │   │       └── JwtProvider.java
│   │   ├── user/
│   │   │   ├── UserController.java
│   │   │   ├── UserService.java
│   │   │   ├── UserRepository.java
│   │   │   ├── User.java                # JPA entity
│   │   │   └── dto/
│   │   │       ├── CreateUserRequest.java
│   │   │       └── UserResponse.java
│   │   └── common/
│   │       ├── exception/
│   │       │   ├── GlobalExceptionHandler.java
│   │       │   ├── NotFoundException.java
│   │       │   └── ErrorResponse.java
│   │       └── BaseEntity.java
│   └── resources/
│       ├── application.yml
│       └── application-test.yml
└── test/
    └── java/com/example/app/
        ├── user/
        │   ├── UserControllerTest.java
        │   └── UserServiceTest.java
        └── auth/
            └── AuthControllerTest.java
```

## Controller / Service / Repository Layers

### Controller

```java
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping
    public List<UserResponse> list() {
        return userService.listUsers();
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UserResponse create(@Valid @RequestBody CreateUserRequest request) {
        return userService.createUser(request);
    }

    @GetMapping("/{id}")
    public UserResponse get(@PathVariable String id) {
        return userService.getUser(id);
    }
}
```

### Service

```java
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserResponse createUser(CreateUserRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ConflictException("Email is already registered.");
        }

        User user = User.builder()
            .id(UUID.randomUUID().toString())
            .email(request.getEmail())
            .password(passwordEncoder.encode(request.getPassword()))
            .build();

        return UserResponse.from(userRepository.save(user));
    }

    public UserResponse getUser(String id) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new NotFoundException("User not found."));
        return UserResponse.from(user);
    }

    @Transactional(readOnly = true)
    public List<UserResponse> listUsers() {
        return userRepository.findAll().stream()
            .map(UserResponse::from)
            .toList();
    }
}
```

### Repository

```java
public interface UserRepository extends JpaRepository<User, String> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
}
```

## Spring Data JPA Entity

```java
@Entity
@Table(name = "users")
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    @Column(length = 120)
    private String id;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;

    @CreationTimestamp
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
```

- Use `@Id` with application-generated UUIDs (VARCHAR(120)) per crew-config conventions.
- Use Lombok (`@Getter`, `@Builder`, `@RequiredArgsConstructor`) to reduce boilerplate.

## Bean Validation with @Valid

```java
public class CreateUserRequest {

    @NotBlank
    @Email
    private String email;

    @NotBlank
    @Size(min = 8, max = 100)
    private String password;
}
```

- Annotate the request body with `@Valid` in the controller.
- Validation errors are handled automatically by the global exception handler.

## Exception Handling with @ControllerAdvice

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(NotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ErrorResponse handleNotFound(NotFoundException ex) {
        return new ErrorResponse("NOT_FOUND", ex.getMessage());
    }

    @ExceptionHandler(ConflictException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    public ErrorResponse handleConflict(ConflictException ex) {
        return new ErrorResponse("CONFLICT", ex.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleValidation(MethodArgumentNotValidException ex) {
        List<Map<String, String>> details = ex.getBindingResult()
            .getFieldErrors().stream()
            .map(e -> Map.of("field", e.getField(), "message", e.getDefaultMessage()))
            .toList();
        return new ErrorResponse("VALIDATION_ERROR", "Input values are invalid.", details);
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ErrorResponse handleUnexpected(Exception ex) {
        log.error("Unhandled exception", ex);
        return new ErrorResponse("INTERNAL_ERROR", "A server error occurred.");
    }
}

public record ErrorResponse(String code, String message, Object details) {
    public ErrorResponse(String code, String message) {
        this(code, message, null);
    }
}
```

## Testing

### Unit Test with Mockito

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock UserRepository userRepository;
    @Mock PasswordEncoder passwordEncoder;
    @InjectMocks UserService userService;

    @Test
    void createUser_success() {
        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("hashed");
        when(userRepository.save(any())).thenAnswer(i -> i.getArgument(0));

        CreateUserRequest request = new CreateUserRequest("test@example.com", "password1");
        UserResponse response = userService.createUser(request);

        assertThat(response.getEmail()).isEqualTo("test@example.com");
        verify(userRepository).save(any(User.class));
    }

    @Test
    void createUser_duplicateEmail_throwsConflict() {
        when(userRepository.existsByEmail(anyString())).thenReturn(true);

        assertThatThrownBy(() -> userService.createUser(
            new CreateUserRequest("dup@example.com", "password1")
        )).isInstanceOf(ConflictException.class);
    }
}
```

### Integration Test with MockMvc

```java
@SpringBootTest
@AutoConfigureMockMvc
class UserControllerTest {

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper objectMapper;

    @Test
    void createUser_returns201() throws Exception {
        CreateUserRequest request = new CreateUserRequest("new@example.com", "StrongP@ss1");

        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.email").value("new@example.com"));
    }

    @Test
    void createUser_invalidEmail_returns400() throws Exception {
        CreateUserRequest request = new CreateUserRequest("invalid", "StrongP@ss1");

        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
    }
}
```

- Use `@SpringBootTest` + `@AutoConfigureMockMvc` for integration tests.
- Use `@DataJpaTest` for repository-only tests.
- Use `@WebMvcTest(UserController.class)` for controller-only tests with mocked services.
- Use `@TestPropertySource` or `application-test.yml` for test configuration.

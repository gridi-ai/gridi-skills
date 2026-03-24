# Test Data Guide

## Email Test Data

### Valid Emails
```
valid@example.com
user.name@example.com
user+tag@example.com
user@subdomain.example.com
```

### Invalid Emails
```
invalid-email
@example.com
user@
user@.com
user@example
user@@example.com
user@exam ple.com
```

## Password Test Data

### Valid Passwords (8+ characters, includes special characters)
```
Test1234!
Password@123
MyP@ssw0rd
```

### Invalid Passwords
```
short1!        # Less than 8 characters
password123    # No special characters
PASSWORD!      # No lowercase letters
password!      # No uppercase letters/digits
12345678!      # No letters
```

## Boundary Value Tests

### String Fields
| Case | Value |
|------|-------|
| Empty value | "" |
| Whitespace only | "   " |
| Minimum length | "a" |
| Minimum length -1 | "" |
| Maximum length | "a" x 255 |
| Maximum length +1 | "a" x 256 |

### Numeric Fields
| Case | Value |
|------|-------|
| 0 | 0 |
| Negative | -1 |
| Minimum value | MIN_VALUE |
| Minimum value -1 | MIN_VALUE - 1 |
| Maximum value | MAX_VALUE |
| Maximum value +1 | MAX_VALUE + 1 |
| Decimal | 1.5 |
| String | "abc" |

## Special Character Tests

### SQL Injection
```
' OR '1'='1
'; DROP TABLE users; --
1' OR '1'='1' /*
```

### XSS
```
<script>alert('xss')</script>
<img src="x" onerror="alert('xss')">
javascript:alert('xss')
```

### Unicode/Special Characters
```
Korean test
Japanese test
Emojis: 👍🏻🎉
Special: !@#$%^&*()
```

## Date Test Data

### Valid Dates
```
2024-01-15
2024-12-31
2024-02-29  # Leap year
```

### Invalid Dates
```
2024-13-01  # Month out of range
2024-02-30  # Non-existent date
2023-02-29  # Not a leap year
0000-00-00
```

## File Upload Tests

### Valid Files
- Allowed extensions: .jpg, .png, .pdf
- Below maximum size
- Valid MIME type

### Invalid Files
- Disallowed extensions: .exe, .sh
- Exceeds maximum size
- Spoofed MIME type
- Empty file
- Corrupted file

## Test Accounts by Environment

### Development Environment
```
Admin: admin@dev.example.com / AdminDev123!
Standard User: user@dev.example.com / UserDev123!
```

### Staging Environment
```
Admin: admin@stg.example.com / AdminStg123!
Standard User: user@stg.example.com / UserStg123!
```

## Test Data Generation Rules

1. **Uniqueness**: Generate test data with unique identifiers including the test case ID
   - Example: `tc001_user@test.com`

2. **Isolation**: Each test uses independent data

3. **Cleanup**: Clean up generated data after tests

4. **Reproducibility**: Must be repeatable with the same test data

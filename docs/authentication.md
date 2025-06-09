# Authentication API Documentation

## Base URL
All endpoints use the base URL: `/api/v1/`

## Authentication
Most endpoints require authentication via the `Authorization` header:
```
Authorization: Token <session_token>
```

---

## User Registration

### POST `/api/v1/signup`
Register a new user account.

**Request:**
```json
{
  "user": {
    "email": "user@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "name": "John Doe"
  }
}
```

**Success Response (201):**
```json
{
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "name": "John Doe"
    },
    "token": "generated_session_token"
  },
  "error": null
}
```

**Error Response (422):**
```json
{
  "data": null,
  "error": {
    "message": "Validation failed",
    "code": "validation_error",
    "details": {
      "email": ["has already been taken"],
      "password": ["is too short"]
    }
  }
}
```

---

## Session Management

### POST `/api/v1/login`
Authenticate user and create session.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Success Response (200):**
```json
{
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "name": "John Doe"
    },
    "token": "generated_session_token"
  },
  "error": null
}
```

**Error Response (401):**
```json
{
  "data": null,
  "error": {
    "message": "Invalid email or password",
    "code": "invalid_credentials"
  }
}
```

### GET `/api/v1/me`
Get current user information. **Requires authentication.**

**Success Response (200):**
```json
{
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "name": "John Doe"
    },
    "session": {
      "created_at": "2025-01-01T12:00:00Z"
    }
  },
  "error": null
}
```

**Error Response (401):**
```json
{
  "data": null,
  "error": {
    "message": "Unauthorized access",
    "code": "unauthorized"
  }
}
```

### DELETE `/api/v1/logout`
End current session. **Requires authentication.**

**Success Response (200):**
```json
{
  "data": {
    "message": "Successfully logged out"
  },
  "error": null
}
```

**Error Response (400):**
```json
{
  "data": null,
  "error": {
    "message": "No session found",
    "code": "no_session"
  }
}
```

---

## Password Reset

### POST `/api/v1/password/forgot`
Request password reset email.

**Request:**
```json
{
  "email": "user@example.com"
}
```

**Success Response (200):**
```json
{
  "data": {
    "message": "If an account exists with that email, you will receive password reset instructions."
  },
  "error": null
}
```

**Note:** This endpoint always returns the same message to prevent email enumeration attacks.

### POST `/api/v1/password/reset`
Reset password using token from email.

**Request:**
```json
{
  "token": "password_reset_token",
  "password": "new_password123"
}
```

**Success Response (200):**
```json
{
  "data": {
    "message": "Password has been reset successfully."
  },
  "error": null
}
```

**Error Response (422):**
```json
{
  "data": null,
  "error": {
    "message": "Invalid or expired token.",
    "code": "invalid_token"
  }
}
```

---

## User Management

### PATCH/PUT `/api/v1/user`
Update user profile. **Requires authentication.**

**Request:**
```json
{
  "user": {
    "email": "newemail@example.com",
    "name": "New Name",
    "password": "newpassword123",
    "password_confirmation": "newpassword123"
  }
}
```

**Success Response (200):**
```json
{
  "data": {
    "user": {
      "id": 1,
      "email": "newemail@example.com",
      "name": "New Name"
    }
  },
  "error": null
}
```

**Error Response (422):**
```json
{
  "data": null,
  "error": {
    "message": "Validation failed",
    "code": "validation_error",
    "details": {
      "email": ["has already been taken"]
    }
  }
}
```

### DELETE `/api/v1/user`
Delete user account. **Requires authentication.**

**Success Response (200):**
```json
{
  "data": {
    "message": "Account deleted successfully"
  },
  "error": null
}
```

**Error Response (422):**
```json
{
  "data": null,
  "error": {
    "message": "Failed to delete account",
    "code": "deletion_failed"
  }
}
```

---

## Success Response Format

All endpoints use consistent success format:

```json
{
  "data": {
    // Response payload - can be an object or array
  },
  "error": null,
  "pagination": { // Optional, only included for paginated list endpoints
    "total": 100,
    "per_page": 20,
    "current_page": 1,
    "next_page": 2,
    "prev_page": null
  }
}
```

### Common Success Response Examples

**Single Resource:**
```json
{
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  },
  "error": null
}
```

**Resource List (with pagination):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com"
    },
    {
      "id": 2,
      "name": "Jane Smith",
      "email": "jane@example.com"
    }
  ],
  "error": null,
  "pagination": {
    "total": 50,
    "per_page": 20,
    "current_page": 1,
    "next_page": 2,
    "prev_page": null
  }
}
```

**Simple Success Message:**
```json
{
  "data": {
    "message": "Operation completed successfully"
  },
  "error": null
}
```

## Error Response Format

All endpoints use consistent error format:

```json
{
  "data": null,
  "error": {
    "message": "Human-readable error message",
    "code": "snake_case_error_code",
    "details": {} // Optional additional details for validation errors
  }
}
```

### Common Error Codes

| Code | Description |
|------|-------------|
| `validation_error` | Input validation failed |
| `invalid_credentials` | Login failed due to wrong email/password |
| `invalid_token` | Password reset token is invalid or expired |
| `unauthorized` | Authentication required but not provided |
| `deletion_failed` | Account deletion failed |
| `no_session` | No active session found for logout |

---

## Security Features

- **Token-based Authentication:** Uses session tokens for API access
- **Email Enumeration Protection:** Password reset always returns same message
- **Session Security:** IP address and user agent validation
- **Content-Type Validation:** Only accepts JSON requests
- **Automatic Token Cleanup:** Expired sessions are automatically removed

---

## Authentication Flow

1. **Registration:** User signs up and receives a session token
2. **Login:** User authenticates and receives a session token
3. **API Access:** Include token in `Authorization` header for protected endpoints
4. **Token Validation:** Server validates token, IP address, and user agent
5. **Logout:** Token is invalidated and session destroyed
# Authentication API Documentation

This document outlines the authentication endpoints available in the API. All endpoints are prefixed with `/api/v1`.

## Authentication Flow

The API uses token-based authentication. After successful login or signup, you'll receive a session token that should be included in subsequent requests in the `Authorization` header using the format: `Token <your_token>`.

## Endpoints

### Sign Up
Creates a new user account and returns a session token.

```http
POST /signup
```

**Request Body:**
```json
{
  "user": {
    "email": "user@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "name": "John Doe"  // optional
  }
}
```

**Success Response (201 Created):**
```json
{
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "name": "John Doe"
    },
    "token": "your_session_token"
  },
  "error": null
}
```

**Error Response (422 Unprocessable Entity):**
```json
{
  "data": null,
  "error": {
    "message": "Validation failed",
    "code": "validation_error",
    "details": {
      "email": ["has already been taken"],
      "password": ["is too short (minimum is 8 characters)"]
    }
  }
}
```

### Login
Authenticates a user and returns a session token.

```http
POST /login
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Success Response (200 OK):**
```json
{
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "name": "John Doe"
    },
    "token": "your_session_token"
  },
  "error": null
}
```

**Error Response (401 Unauthorized):**
```json
{
  "data": null,
  "error": {
    "message": "Invalid email or password",
    "code": "invalid_credentials"
  }
}
```

### Get Current User
Returns information about the currently authenticated user.

```http
GET /me
```

**Headers:**
```
Authorization: Token your_session_token
```

**Success Response (200 OK):**
```json
{
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "name": "John Doe"
    },
    "session": {
      "last_seen_at": "2025-06-08T09:44:39.373Z",
      "created_at": "2025-06-08T09:43:02.859Z"
    }
  },
  "error": null
}
```

**Error Response (401 Unauthorized):**
```json
{
  "data": null,
  "error": {
    "message": "You need to sign in or sign up before continuing.",
    "code": "unauthorized"
  }
}
```

### Logout
Invalidates the current session token.

```http
DELETE /logout
```

**Headers:**
```
Authorization: Token your_session_token
```

**Success Response (200 OK):**
```json
{
  "data": {
    "message": "Successfully logged out"
  },
  "error": null
}
```

**Error Response (400 Bad Request):**
```json
{
  "data": null,
  "error": {
    "message": "No active session found",
    "code": "no_active_session"
  }
}
```

### Request Password Reset
Initiates the password reset process by sending a reset link to the user's email.

```http
POST /password/forgot
```

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Success Response (200 OK):**
```json
{
  "data": {
    "message": "If an account exists with that email, you will receive password reset instructions."
  },
  "error": null
}
```

Note: For security reasons, this endpoint returns the same response regardless of whether the email exists in the system.

### Reset Password
Resets the user's password using a valid reset token.

```http
POST /password/reset
```

**Request Body:**
```json
{
  "token": "reset_token_from_email",
  "password": "new_password123"
}
```

**Success Response (200 OK):**
```json
{
  "data": {
    "message": "Password has been reset successfully."
  },
  "error": null
}
```

**Error Response (422 Unprocessable Entity):**
```json
{
  "data": null,
  "error": {
    "message": "Invalid or expired token.",
    "code": "invalid_token"
  }
}
```

## Security Features

- Session tokens are securely hashed using BCrypt before storage
- Password reset tokens expire after 1 hour
- Sessions track user agent and IP address to prevent session hijacking
- Passwords are validated for minimum length (8 characters)
- Email addresses are stored and compared case-insensitively
- All sensitive parameters are filtered from logs
- Tokens are automatically invalidated on logout
- Sessions can be invalidated server-side
- Protection against email enumeration attacks 
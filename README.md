# Rails API Starter Template with Supabase-style Responses

A Rails 8 API-only starter template with authentication baked in, following Supabase-style JSON response conventions. This template provides a solid foundation for building modern APIs with consistent response structures.

## Features

- **Rails 8 API-only Application**
- **Built-in Authentication System**
- **Supabase-style JSON Responses**
- **Consistent Error Handling**
- **API Documentation**

## Response Convention

All API responses follow a consistent Supabase-style structure, making it easy for frontend applications to handle both successful and error responses.

### Success Response Structure

```json
{
  "data": { /* your payload */ },
  "error": null
}
```

Example success response:
```json
{
  "data": {
    "id": 1,
    "name": "John Smith",
    "email": "john@example.com"
  },
  "error": null
}
```

### Error Response Structure

```json
{
  "data": null,
  "error": {
    "message": "Human-readable error message",
    "code": "error_code",
    "details": { /* optional additional context */ }
  }
}
```

Example error response:
```json
{
  "data": null,
  "error": {
    "message": "Validation failed",
    "code": "validation_error",
    "details": {
      "email": ["can't be blank", "is invalid"]
    }
  }
}
```

### Pagination Response Structure

For endpoints that return lists of resources:

```json
{
  "data": [ /* array of items */ ],
  "error": null,
  "pagination": {
    "total": 25,
    "per_page": 10,
    "current_page": 1,
    "next_page": 2,
    "prev_page": null
  }
}
```

## Response Helpers

The template includes two main helper methods for rendering responses:

### `render_success`

```ruby
render_success(
  data: { id: 1, name: "John" },
  status: :ok,
  pagination: { total: 25, per_page: 10 } # optional
)
```

### `render_error`

```ruby
render_error(
  message: "Resource not found",
  code: "not_found",
  status: :not_found,
  details: { id: ["invalid"] } # optional
)
```

## Authentication Features

- Sign up with email/password
- Login with email/password
- Session token authentication
- Password reset functionality
- Current user endpoint
- Logout functionality

For detailed authentication documentation, see [docs/authentication.md](docs/authentication.md).

## Getting Started

1. Clone this repository
2. Run `bundle install`
3. Set up your database: `rails db:create db:migrate`
4. Start the server: `rails server`

## API Documentation

- Authentication endpoints documentation can be found in [docs/authentication.md](docs/authentication.md)
- All API responses follow the Supabase-style convention detailed above

## Contributing

Bug reports and pull requests are welcome. This project is intended to be a safe, welcoming space for collaboration.

## Security

If you find any security vulnerabilities, please create an issue or a pull request with a remedy.

## License

This project is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

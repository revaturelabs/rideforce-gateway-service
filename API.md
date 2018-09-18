# Rideshare back-end API

This document serves as the central location for the project's API
documentation, including types used in requests/responses as well as the
endpoints themselves.

TODO: change endpoint names and types as necessary.

## Types

All communication with the API is done via JSON. The types in this section
are described in TypeScript syntax; assume that strict null checking is
enabled, so that any fields not explicitly marked as nullable (`?`) are not
nullable.

### General types

The types in this section are not tied to any particular service or endpoint;
they are used across services.

#### `ApiError`

This is the type used for all error responses. Any response with an HTTP
status code in the 400 or 500 series should have a body with this format.

```ts
{
  /**
   * The primary message corresponding to the error.
   */
  message: string;
  /**
   * Any additional details, such which fields were missing/incorrect in a
   * request format error. An empty array indicates that there are no such
   * details.
   */
  details: string[];
}
```

### User service (`/users`)

### Map service (`/maps`)

### Matching service (`/matches`)

## Endpoints

### User service (`/users`)

### Map service (`/maps`)

### Matching service (`/matches`)

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

#### `Link<T>`

This is an alias for `string` that indicates that the value of the property
is a link to another API resource. All link values are URIs relative to the
main API endpoint. For example, the link to the user with ID 56 might be
`/users/56`.

The type parameter `T` indicates the type of the resource to which the link
points (for documentation), and is not actually useful for type checking.

### User service (`/users`)

#### `User`

A user of the rideshare service. The user's password is not included in this
type, because including it in API responses is unnecessary and a security
risk.

```ts
{
  /**
   * The ID of the user in the database.
   */
  id: number;
  firstName: string;
  lastName: string;
  email: string;
  /**
   * The user's home address (where they currently live).
   */
  address: Link<Address>;
  /**
   * The user's office (where they work).
   */
  office: Link<Office>;
  /**
   * The end date of the batch, in the format (yyyy-MM-dd'T'HH:mm:ss.SSS'Z').
   */
  batchEnd: string;
  cars: Link<Car>[];
  /**
   * The user's Venmo username.
   */
  venmo?: string;
  /**
   * The user's contact information.
   */
  contactInfo: Link<ContactInfo>[];
  /**
   * Whether the user's account is active.
   */
  active: boolean;
  /**
   * The user's role, determining what permissions they have to access data on
   * the server.
   */
  role: Role;
}
```

#### `Address`

An address, as would be written on a form. This is distinct from the
`Address` type used with the map service in that there is an ID.

```ts
{
  /**
   * The ID of the address in the database.
   */
  id: number;
  /**
   * The first line of the address.
   */
  address: string;
  /**
   * The second line of the address.
   */
  address2?: string;
  city: string;
  state: string;
  zip: string;
}
```

#### `Office`

A Revature office where users work.

```ts
{
  /**
   * The ID of the office in the database.
   */
  id: number;
  /**
   * The common name of the office (e.g. "Reston").
   */
  name: string;
  address: Link<Address>;
}
```

#### `Car`

A user's car.

```ts
{
  /**
   * The ID of the car in the database.
   */
  id: number;
  make: string;
  model: string;
  year: number;
}
```

#### `ContactInfo`

A single method of contact for a user.

```ts
{
  /**
   * The ID of this contact info entry in the database.
   */
  id: number;
  type: ContactInfoType;
  /**
   * The details specifying the user's username/phone number/etc. on the
   * service.
   */
  info: string;
}
```

#### `Role` (enum)

TODO

#### `ContactInfoType` (enum)

TODO

### Map service (`/maps`)

#### `Address`

An address, as would be written on a form. This is distinct from the
`Address` type used with the user service in that there is no ID.

```ts
{
  /**
   * The first line of the address.
   */
  address: string;
  /**
   * The second line of the address.
   */
  address2?: string;
  city: string;
  state: string;
  zip: string;
}
```

#### `Location`

A geographical location, in terms of its coordinates.

```ts
{
  latitude: number;
  longitude: number;
}
```

#### `RouteInfo`

All the necessary information about a walking route from one point to
another. Currently, this does not include any directions; the user only needs
to know how long it takes to get from one point to another, as well as the
distance.

```ts
{
  /**
   * The total route distance, in meters.
   */
  distance: number;
  /**
   * The total route time, in seconds.
   */
  time: number;
}
```

### Matching service (`/matches`)

## Endpoints

### User service (`/users`)

TODO: describe standard for CRUD operation endpoints.

### Map service (`/maps`)

### Matching service (`/matches`)

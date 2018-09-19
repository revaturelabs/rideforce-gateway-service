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

### `ApiError`

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

### `Link<T>`

This is an alias for `string` that indicates that the value of the property
is a link to another API resource. All link values are URIs relative to the
main API endpoint. For example, the link to the user with ID 56 might be
`/users/56`.

The type parameter `T` indicates the type of the resource to which the link
points (for documentation), and is not actually useful for type checking.

### `User`

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
  address: Link<AddressWithId>;
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
### `Address`

An address, as would be written on a form. This is distinct from the
`AddressWithId` type used with the user service in that there is no ID.

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

### `AddressWithId`

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

### `Location`

A geographical location, in terms of its coordinates.

```ts
{
  latitude: number;
  longitude: number;
}
```

### `Office`

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

### `Car`

A user's car.

```ts
{
  /**
   * The ID of the car in the database.
   */
  id: number;
  /**
   * The owner of this car.
   */
  owner: Link<User>;
  make: string;
  model: string;
  year: number;
}
```

### `ContactInfo`

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

### `RouteInfo`

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

### `Role` (enum)

TODO

### `ContactInfoType` (enum)

TODO

### Matching service (`/matches`)

## Endpoints

The endpoints are documented by service (or pseudo-service; see below); each
endpoint within a service is marked by a header including the method (e.g.
`GET`) and the URI (e.g. `/location`). Path parameters are listed in Express
format (e.g. `/:id`), and query parameters are listed as well (e.g.
`/?email`) if they are mandatory for a particular route. Within each
endpoint, the request/response body formats are documented, along with
possible response status codes.

Besides the response body format(s) listed, a `ResponseError` can always be
returned in the event of an unsuccessful request (this will never be
mentioned explicitly in the response body type). Additionally, any status
code in the 500 series, as well as 400 (bad request) and 403 (forbidden) may
be included with the response, regardless of whether this is explicitly
documented.

Please note that not all of the top-level endpoints necessarily correspond to
a distinct microservice; this is a low-level implementation detail that is
subject to change. Routing requests to each top-level endpoint to the proper
service is handled by the gateway service.

### `/login`

#### `GET /`

A convenience method which parses the JWT given as authentication and
redirects to the currently logged-in user (e.g. `/users/32` if the user with
ID 32 is logged in).

**Response status**: 302 (found)

#### `POST /`

Attempts to log a user in using the given credentials.

**Request body**: `{ email: string, password: string }`

**Response status**: 200 (OK)

**Response body**: `string` (a JSON Web Token that can be used for
authentication)

### `/users`

#### `GET /`

Returns all users.

**Response status**: 200 (OK)

**Response body**: `User[]`

#### `GET /?email`

Returns a single user by email address.

**Response status**: 200 (OK) or 404 (not found)

**Response body**: `User`

#### `GET /:id`

Returns a single user by ID.

**Response status**: 200 (OK) or 404 (not found)

**Response body**: `User`

#### `POST /`

Creates a new user.

**Request body**: `{ user: User, password: string }` (the `id` parameter can
be omitted from the user object, and will be ignored if it is present)

**Response status**: 201 (created)

**Response body**: `User`

### `/addresses`

### `/offices`

### `/cars`

### `/maps`

### `/contact-info`

#### `GET /location`

TODO: how do we pass in an address as a parameter?

**Response status**: 200 (OK)

**Response body**: `Location`

#### `GET /route`

TODO: how do we pass in two addresses as parameters?

**Response status**: 200 (OK)

**Response body**: `Route`

### `/matches`

# RideForce back-end API

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

A user of the RideForce service. The user's password is not included in this
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
   * The URL to the user's profile photo.
   */
  photoUrl?: string;
  /**
   * The user's bio (a short "about me" description). Limit to 200 characters.
   */
  bio?: string;
  /**
   * The user's home address (where they currently live).
   */
  address: string;
  /**
   * The user's office (where they work).
   */
  office: Link<Office>;
  /**
   * The end date of the batch, in the format (yyyy-MM-dd'T'HH:mm:ss.SSS'Z').
   */
  batchEnd?: string;
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
  address: string;
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

### `Location`

A geographical location, in terms of its coordinates.

```ts
{
  lat: number;
  lng: number;
}
```

### `FavoriteLocation`

A geographical location saved by the user, in terms of its coordinates.

```ts
{
  lat: number;
  lng: number;
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
  duration: number;
}
```

### `Role` (enum)

The role of a user of the ridesharing service.

```ts
{
  Driver = 'DRIVER',
  Rider = 'RIDER',
  Trainer = 'TRAINER',
  Admin = 'ADMIN',
}
```

### `ContactInfoType` (enum)

TODO: fill this in with more types.

```ts
{
  Phone = 'PHONE',
  Slack = 'SLACK',
  Skype = 'SKYPE',
  Other = 'OTHER',
}
```

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

Finally, when implementing these endpoints, please be sure to follow the
relevant HTTP conventions for each method: for example, when responding to a
POST request with a status of 201 (created), please set the
`Content-Location` header to a link to the newly created resource (in
addition to returning the resource itself).

### Standard CRUD operations

For brevity and clarity, an endpoint may specify that it supports "basic CRUD
operations" without explicitly listing the methods below:

- `GET /`: retrieves a list of all resources.
- `GET /:id`: retrieves a resource by ID, returning the resource with a
  status of 200 (OK) or an error with a status of 404 (not found).
- `POST /`: inserts a new resource, ignoring any ID property in the request
  body. Returns the newly created resource, along with a status of 201
  (created) or 409 (conflict; if a conflicting resource already exists).
- `PUT /:id`: updates an existing resource, returning the updated resource
  with a status of 200 (OK) or an error with a status of 409 (conflict; if
  another resource would conflict with the changes).

The `DELETE` method is intentionally omitted for now.

Other methods that do not correspond to one in the list above will be
mentioned explicitly in more detail.

### `/registration-key`

#### `GET /`

Generates a key that can be used to create new users. Keys expire after 2
hours. Only trainers and admins can create new registration keys.

**Response status**: 200 (OK)

**Response body**: `string` (a JSON Web Token that can be used as a
registration key)

### `/login`

#### `GET /`

A convenience method which parses the JWT given as authentication and
returns the currently logged-in user.

Note: it would be more logical for this method to return a status of 302
(found) with the `Location` header set to the URI of the user, but this
[causes CORS issues on
Firefox](https://bugzilla.mozilla.org/show_bug.cgi?id=1444278) and possibly
other browsers as well. Thus, until all browsers catch up to the standard
(which was updated two years ago), we have to simply return the user object
here.

**Response status**: 200 (OK)

**Response body**: `User`

#### `POST /`

Attempts to log a user in using the given credentials.

**Request body**: `{ email: string, password: string }`

**Response status**: 200 (OK)

**Response body**: `string` (a JSON Web Token that can be used for
authentication)

### `/users`

Supports basic CRUD operations for `User`, except for `POST /` which is as
documented below.

#### `POST /`

Creates a new user with the given password. The registration key must also be
provided.

**Request body**: `{ user: User, password: string, registrationKey: string }`

**Response status**: 201 (created) or 409 (conflict)

**Response body**: `User`

#### `GET /?email`

Returns a single user by email address.

**Response status**: 200 (OK) or 404 (not found)

**Response body**: `User`

#### `GET /?office&role`

Returns all users who work at the given office and have the given role.

**Request parameters**: `office: number` (the office ID); `role: string` (the
role string, e.g. `DRIVER`)

**Reponse status**: 200 (OK) or 404 (not found; if the office ID does not
correspond to an office)

**Response body**: `User[]`

#### `PUT /:id/password`

Updates the password of the user with the given ID. Confirmation of the old
password is required to set a new password.

**Request body**: `{ old: string, new: string }`

**Response status**: 200 (OK), 403 (forbidden; if the old password was
incorrect, or due to any other authentication issue such as not being logged
in) or 404 (if the user does not exist)

**Response body**: `void`

### `/offices`

Supports basic CRUD operations for `Office`.

### `/cars`

Supports basic CRUD operations for `Car`.

### `/contact-info`

Supports basic CRUD operations for `ContactInfo`.

### `/roles`

Supports basic CRUD operations for `Role`.

### `/contact-types`

Supports basic CRUD operations for `ContactType`.

### `/location`

#### `GET /?address`

Returns the geographical coordinates of an address.

**Request parameters**: `address: string`

**Response status**: 200 (OK)

**Response body**: `Location`

### `/favoritelocations`

#### `GET /users/{id}?address={address}`

Returns the geographical coordinates of a user-saved address.

**Request parameters**: `address: string`

**Path variables**: `userId: int`

**Response status**: 200 (OK)

**Response body**: `Location`

### `/route`

#### `GET /?start&end`

Returns route information for walking directions between two points.

**Request parameters**: `start: string`; `end: string`

**Response status**: 200 (OK)

**Response body**: `Route`

### `/matches`

#### `GET /:id`

Returns all drivers who match the rider with the given user ID.

**Response status**: 200 (OK) or 404 (not found; if the user ID does not
correspond to a user)

**Response body**: `Link<User>[]`

### `/likes`

#### `GET /:id`

Returns all users liked by the user with the given ID.

**Response status**: 200 (OK) or 404 (not found; if the user ID does not
correspond to a user)

**Response body**: `Link<User>[]`

#### `PUT /:id/:liked`

Indicates that the user with ID `:id` likes the user with ID `:liked`.

**Response status**: 201 (created; if a new like was added), 204 (no content;
if the like was already in the system) or 404 (not found; if either user ID
does not correspond to a user)

**Response body**: `void`

#### `DELETE /:id/:liked`

Removes any indication that the user with ID `:id` likes the user with ID
`:liked`.

**Response status**: 204 (no content; if the like was successfully deleted,
including if there was no like to begin with) or 404 (not found; if either
user ID does not correspond to a user)

**Response body**: `void`

### `/dislikes`

The methods for this endpoint are the same as those for `/likes`, but
applying to dislikes rather than likes. Explicit descriptions are omitted for
brevity.

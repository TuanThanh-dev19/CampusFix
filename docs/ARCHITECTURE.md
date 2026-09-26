# Nexora architecture

## Backend modules

```text
com.nexora
├── config         Security, CORS, OpenAPI, persistence configuration
├── common         Cross-cutting exceptions, health, pagination, storage
├── auth           Login, access-token handling and current user
├── user           User, role, permission and technician profile
├── location       Campus, building, floor, room/area
├── asset          Equipment type, equipment and status history
├── category       Incident category, form versions and dynamic validation
├── ticket         Report, assignment, workflow, work log and attachments
├── notification   MongoDB notification documents and delivery state
├── audit          Append-only MongoDB audit events
├── migration      Idempotent legacy SQL-to-MongoDB backfill
└── dashboard      Aggregated metrics and SLA reports
```

Feedback belongs to the ticket module in the MVP. Audit events, ticket comments,
and notifications use Spring Data MongoDB. All strongly relational entities
remain in SQL Server and use JPA/JDBC. Cross-database references are scalar SQL
IDs validated by the service layer, never MongoDB `DBRef` values.

Writes that describe an already committed SQL transaction are published as
application events and persisted to MongoDB with an `AFTER_COMMIT` listener.
MongoDB failures are logged explicitly and cannot roll back the completed SQL
transaction.

Inside each feature, add only the layers it needs:

```text
ticket/
├── controller/
├── dto/request/
├── dto/response/
├── entity/
├── repository/
├── service/
└── workflow/
```

Add `specification/` only when ticket search/filter logic becomes complex enough to need dedicated JPA specifications.

Keep the application as a modular monolith for the eight-week MVP. Microservices, Kafka, Redis, and a separate state-machine framework are not required.

## Frontend modules

```text
src/
├── app/
│   ├── router.jsx          Route-to-page mapping
│   ├── providers.jsx       Query and authentication providers
│   ├── queryClient.js
│   └── routes/             ProtectedRoute and RequireRole
├── features/
│   ├── auth/
│   │   ├── components/
│   │   ├── context/
│   │   ├── pages/
│   │   └── schemas/
│   ├── tickets/
│   │   ├── api/
│   │   ├── components/
│   │   ├── constants/
│   │   ├── hooks/
│   │   ├── pages/
│   ├── assets/
│   ├── categories/
│   ├── dashboard/
│   └── home/
├── shared/
│   ├── api/                Shared Axios client and error handling
│   ├── components/         Cross-feature reusable UI
│   ├── hooks/
│   ├── layouts/
│   ├── styles/
│   ├── constants/
│   └── utils/
├── test/                   Shared test setup and mocks
├── App.jsx
└── main.jsx                Browser entry point
```

Rules:

- Pages and UI components do not call Axios directly.
- Use `.jsx` for files that render JSX and `.js` for plain JavaScript modules. The frontend does not use TypeScript or TSX.
- A feature keeps its API calls and query hooks within that feature.
- A page represents a complete routed screen; `components` contains smaller reusable UI pieces.
- TanStack Query owns server state; Context owns only small client state such as the authenticated user.
- Filters, sorting, and pagination should be represented in URL search parameters.
- Route guards improve UX, but Spring Security still enforces authorization.

## Recommended ticket workflow

```text
SUBMITTED → UNDER_REVIEW → ASSIGNED → IN_PROGRESS → RESOLVED → CLOSED
```

The canonical SQL Server status set also includes `REOPENED`, `REJECTED`, and
`CANCELLED`. Display labels remain separate from these stored/API codes. Ticket
transition behavior, including reopening a resolved ticket, belongs to tested
Java policy code and is implemented separately from the vocabulary contract. Do
not expose a generic endpoint that lets the client assign any status.

## Dynamic category forms

An administrator creates a category, edits a draft form version, validates it, and publishes it. Published versions are immutable. Each ticket stores the form version used when it was created, so later category changes do not invalidate historical reports.

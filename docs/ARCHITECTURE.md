# CampusFix architecture

## Backend modules

```text
com.campusfix
├── config         Security, CORS, OpenAPI, persistence configuration
├── common         Cross-cutting exceptions, health, pagination, storage
├── auth           Login, access-token handling and current user
├── user           User, role, permission and technician profile
├── location       Campus, building, floor, room/area
├── asset          Equipment type, equipment and status history
├── category       Incident category, form versions and dynamic validation
├── ticket         Report, assignment, workflow, work log and attachments
└── dashboard      Aggregated metrics and SLA reports
```

Feedback belongs to the ticket module in the MVP. Notification, audit, and reviewed false-report cases are optional modules and should only be added when the team actually implements them.

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

The MVP also supports `REJECTED` and `CANCELLED`. `DUPLICATE` and `REOPENED` are optional extensions. When reopening a resolved ticket, clear its current `resolved_at`; the previous resolution event remains in `ticket_status_history`. Implement transitions as tested Java policy code. Do not expose a generic endpoint that lets the client assign any status.

## Dynamic category forms

An administrator creates a category, edits a draft form version, validates it, and publishes it. Published versions are immutable. Each ticket stores the form version used when it was created, so later category changes do not invalidate historical reports.

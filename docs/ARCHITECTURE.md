# CampusFix architecture

## Backend modules

```text
com.campusfix
├── config         Security, CORS, OpenAPI, persistence configuration
├── common         Cross-cutting exceptions, health, pagination, storage
├── auth           Login, token issuing/refresh, current user
├── identity       User, role, permission and technician profile
├── location       Campus, building, floor, room/area
├── asset          Equipment type, equipment and status history
├── category       Incident category, form versions and dynamic validation
├── ticket         Report, assignment, workflow, work log and attachments
├── feedback       Requester rating and resolution feedback
├── dashboard      Aggregated metrics and SLA reports
├── notification   In-app/email notification orchestration
├── audit          Security and administrative audit trail
└── violation      Optional reviewed false-report cases (post-MVP)
```

Inside each feature, add only the layers it needs:

```text
ticket/
├── controller/
├── dto/request/
├── dto/response/
├── entity/
├── repository/
├── service/
├── specification/
└── workflow/
```

Keep the application as a modular monolith for the eight-week MVP. Microservices, Kafka, Redis, and a separate state-machine framework are not required.

## Frontend modules

```text
src/
├── app/            Router, providers and query client
├── layouts/        Shared page shells
├── routes/         Authentication/authorization route guards
├── features/       Business features matching backend modules
├── shared/         Reusable API client, UI, types, config and utilities
├── test/           Shared test setup and mocks
└── main.tsx        Browser entry point
```

Rules:

- Pages and UI components do not call Axios directly.
- A feature keeps its API calls and query hooks within that feature.
- TanStack Query owns server state; Context owns only small client state such as the authenticated user.
- Filters, sorting, and pagination should be represented in URL search parameters.
- Route guards improve UX, but Spring Security still enforces authorization.

## Recommended ticket workflow

```text
SUBMITTED → UNDER_REVIEW → ASSIGNED → IN_PROGRESS → RESOLVED → CLOSED
```

Supported branches can include `REJECTED`, `DUPLICATE`, `CANCELLED`, and `REOPENED`. Implement transitions as tested Java policy code. Do not expose a generic endpoint that lets the client assign any status.

## Dynamic category forms

An administrator creates a category, edits a draft form version, validates it, and publishes it. Published versions are immutable. Each ticket stores the form version used when it was created, so later category changes do not invalidate historical reports.

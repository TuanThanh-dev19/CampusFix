# Frontend feature convention

Each business feature owns the code that changes together:

```text
features/tickets/
├── api/          Axios calls for ticket endpoints
├── components/   Reusable ticket UI pieces
├── hooks/        Query/mutation and feature state logic
├── pages/        Route-level ticket screens
├── schemas/      Client-side form validation
└── types/        Ticket-specific TypeScript contracts
```

Do not create every folder in advance. Add a folder when the feature has a real file for it.

Files such as `ticketApi.ts`, `useTickets.ts`, and the current ticket list are starter examples. A feature is complete only after its page, hook, API, backend endpoint, validation, authorization, and tests are connected in an end-to-end flow.

- Put cross-feature UI in `shared/components`.
- Put application composition, routing, and providers in `app`.
- A page is also a React component, but it represents a complete URL-level screen.
- Backend authorization and validation remain authoritative; frontend guards and validation only improve user experience.

# CampusFix frontend

React + TypeScript single-page application for CampusFix.

```bash
npm install
npm run dev
npm run lint
npm run test
npm run build
```

The codebase is organized by business feature. Keep HTTP calls in a feature API module, server state in TanStack Query hooks, and only small client state such as the current user in Context.

```text
src/
├── app/                  Router, providers, route guards
├── features/
│   ├── auth/             components, context, pages, schemas
│   ├── tickets/          api, components, hooks, pages, types
│   ├── dashboard/        components, pages
│   ├── assets/           components, types
│   └── categories/       components, types
├── shared/               Cross-feature components, layouts, hooks, utilities
├── test/
├── App.tsx
└── main.tsx
```

`features` is not another name for `components`. A feature is a business module; it may contain components, pages, API calls, hooks, validation schemas, and types. Read `src/features/README.md` before adding a new feature.

The current sign-in screen deliberately contains a UI-only demo session so route and role guards can be reviewed before the backend authentication endpoints exist. It stores no token. Replace `loginDemo` with the real authentication flow before implementing real users.

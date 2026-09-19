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

The current sign-in screen deliberately contains a UI-only demo session so route and role guards can be reviewed before the backend authentication endpoints exist. It stores no token. Replace `loginDemo` with the real authentication flow before implementing real users.

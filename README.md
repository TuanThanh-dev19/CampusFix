# CampusFix

CampusFix is a campus incident reporting, maintenance workflow, and equipment tracking platform. This repository is a modular monolith: one Spring Boot API and one React single-page application.

## Technology

- Backend: Java 21, Spring Boot 4.1, Maven, Spring Security, JPA, Bean Validation, Flyway, PostgreSQL.
- Frontend: React 19, TypeScript, Vite, React Router, Axios, TanStack Query, React Bootstrap.
- Tests: JUnit/Spring Test and Vitest/React Testing Library.
- Local infrastructure: Docker Compose with PostgreSQL.

## Repository layout

```text
campusfix/
├── backend/          Spring Boot REST API
├── frontend/         React SPA
├── docs/             Architecture and team documentation
├── infrastructure/   Infrastructure-specific notes/configuration
├── .github/          CI and pull-request template
├── compose.yaml      Local PostgreSQL
└── .env.example      Safe environment-variable template
```

The backend uses **package by feature** (`ticket`, `asset`, `category`, ...). The frontend follows the same idea under `src/features`. This reduces merge conflicts and lets each team member own a feature end to end.

## First run

Requirements: Java 21, Node.js 22.12+ or 24+, Docker Desktop, and Git.

```bash
copy .env.example .env
docker compose up -d
```

Start the backend:

```bash
cd backend
./mvnw spring-boot:run
```

On Windows PowerShell use `./mvnw.cmd spring-boot:run`.

Start the frontend in another terminal:

```bash
cd frontend
npm install
npm run dev
```

- Frontend: http://localhost:5173
- Backend health endpoint: http://localhost:8080/api/v1/public/health
- Actuator health: http://localhost:8080/actuator/health

## Quality commands

```bash
cd backend
./mvnw verify

cd ../frontend
npm run lint
npm run test
npm run build
```

## Development rules

- Never commit `.env`, passwords, JWT keys, or production credentials.
- Do not expose JPA entities directly from controllers; use request/response DTOs.
- Controllers handle HTTP, services enforce business rules, repositories handle persistence.
- The backend is the final authority for permissions, validation, and status transitions.
- Use Flyway migrations; do not enable `ddl-auto=update`.
- Create one branch per task: `feat/ticket-workflow`, `fix/category-validation`, etc.
- Open a pull request to `main` and ask at least one teammate to review it.

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and [docs/GITHUB_SETUP.md](docs/GITHUB_SETUP.md).

For the SBA301-oriented folder conventions and team ownership rules, see [docs/PROJECT_STRUCTURE_SBA301.md](docs/PROJECT_STRUCTURE_SBA301.md).

> Version note: this starter currently uses Spring Boot 4.1 and React with TypeScript. SBA301 does not publish a single mandatory folder tree publicly. If your lecturer provides a Spring Boot 3 or JavaScript-only starter/rubric, use that exact version and language requirement before developing domain features; the same folder responsibilities still apply.

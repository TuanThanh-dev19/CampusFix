# Nexora

Nexora is a campus incident reporting, maintenance workflow, and equipment tracking platform. The repository is a modular monolith containing one Spring Boot REST API and one React single-page application.

## Technology

- Backend: Java 21, Spring Boot 4.1, Maven, Spring Security, JPA, Bean Validation, Flyway.
- Database: Microsoft SQL Server 2022 Developer.
- Frontend: ReactJS 19, JavaScript/JSX, Vite, React Router, Axios, TanStack Query, React Bootstrap.
- Tests: JUnit/Spring Test, SQL Server Testcontainers, Vitest/React Testing Library.
- Local infrastructure: Docker Compose with a persistent SQL Server volume.

## Repository layout

```text
nexora/
├── backend/          Spring Boot REST API and Flyway migrations
├── frontend/         React SPA
├── docs/             Architecture and team documentation
├── infrastructure/   SQL Server initialization support
├── .github/          CI and pull-request template
├── compose.yaml      Local SQL Server 2022
└── .env.example      Local environment template
```

The backend uses package by feature (`ticket`, `asset`, `category`, ...). The frontend follows the same feature boundaries under `src/features`, allowing teammates to own vertical slices end to end.

## First run

Requirements: Java 21, Node.js 22.12+ or 24+, Docker Desktop, and Git. Docker Desktop must be running.

From the repository root in PowerShell:

```powershell
Copy-Item .env.example .env
docker compose config
docker compose up -d
docker compose ps -a
```

Expected result:

- `sqlserver` becomes `healthy`.
- `sqlserver-init` becomes `Exited (0)` after creating the `nexora` database. This is normal.
- Spring Boot then runs Flyway to create tables, constraints, indexes, and reference data.

Start the backend:

```powershell
cd backend
.\mvnw.cmd spring-boot:run
```

Start the frontend in another terminal:

```powershell
cd frontend
npm install
npm run dev
```

- Frontend: http://localhost:5173
- Backend health endpoint: http://localhost:8080/api/v1/public/health
- Actuator health: http://localhost:8080/actuator/health
- Swagger UI: http://localhost:8080/swagger-ui.html

The root `.env` file is read by Docker Compose, but it is not automatically loaded by a Spring Boot process started directly on Windows. Defaults already match `.env.example`. If a teammate changes the port or password, they must also configure `DB_URL`, `DB_USERNAME`, and `DB_PASSWORD` in the terminal or IDE run configuration.

## Database connection

Use these local settings in SQL Server Management Studio or another SQL client:

```text
Server: localhost,1433
Authentication: SQL Server Authentication
Login: sa
Password: value of MSSQL_SA_PASSWORD in .env
Database: nexora
Trust server certificate: enabled for local development only
```

Local JDBC URL:

```text
jdbc:sqlserver://localhost:1433;databaseName=nexora;encrypt=true;trustServerCertificate=true
```

See [docs/SQLSERVER_DOCKER_GUIDE.md](docs/SQLSERVER_DOCKER_GUIDE.md) for the complete team setup, daily commands, migrations, troubleshooting, and safe reset procedure.

## Quality commands

```powershell
cd backend
.\mvnw.cmd verify

cd ..\frontend
npm run lint
npm run test
npm run build
```

The fast backend suite uses H2 in SQL Server compatibility mode. To verify real T-SQL migrations with Testcontainers, Docker Desktop must be running:

```powershell
cd backend
$env:RUN_SQLSERVER_IT='true'
.\mvnw.cmd -Dtest=SqlServerMigrationIntegrationTest test
Remove-Item Env:RUN_SQLSERVER_IT
```

## Development rules

- Never commit `.env`, passwords, JWT keys, or production credentials.
- Do not expose JPA entities directly from controllers; use request/response DTOs.
- Controllers handle HTTP, services enforce business rules, repositories handle persistence.
- The backend is the final authority for permissions, dynamic validation, and status transitions.
- Use Flyway migrations and keep `ddl-auto=validate`; never use `ddl-auto=update`.
- Never modify an applied migration. Add the next migration version instead.
- Create one branch per task, for example `feat/ticket-workflow` or `fix/category-validation`.
- Open a pull request to `main` and ask at least one teammate to review it.
- `trustServerCertificate=true` is only for the self-signed local container; deployed environments must use a trusted certificate.

Further documentation:

- [Architecture](docs/ARCHITECTURE.md)
- [SBA301 project structure](docs/PROJECT_STRUCTURE_SBA301.md)
- [GitHub setup](docs/GITHUB_SETUP.md)
- [SQL Server and Docker team guide](docs/SQLSERVER_DOCKER_GUIDE.md)
- [ERD to SQL Server schema mapping](docs/DATABASE_SCHEMA.md)

> Version note: this starter uses Spring Boot 4.1 and ReactJS with JavaScript/JSX. The frontend has no TypeScript compilation step. If the lecturer provides a mandatory Spring Boot 3 starter, follow that rubric while keeping the same feature boundaries and workflow rules.

# Nexora backend

This is the Spring Boot 3.5 REST API. It uses a package-by-feature modular
monolith with SQL Server for relational data and MongoDB for audit events,
ticket comments, and notifications.

Create each feature's `controller`, `dto`, `entity`, `repository`, and `service` packages only when needed. Business workflow rules belong in services or dedicated policy classes, never in controllers.

Common commands:

```bash
./mvnw spring-boot:run
./mvnw verify
```

Swagger UI is available at http://localhost:8080/swagger-ui.html while the application is running.

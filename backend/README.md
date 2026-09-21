# Nexora backend

This is the Spring Boot REST API. It uses a package-by-feature modular monolith.

Create each feature's `controller`, `dto`, `entity`, `repository`, and `service` packages only when needed. Business workflow rules belong in services or dedicated policy classes, never in controllers.

Common commands:

```bash
./mvnw spring-boot:run
./mvnw verify
```

Swagger UI is available at http://localhost:8080/swagger-ui.html while the application is running.

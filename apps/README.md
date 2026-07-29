# Applications

Application source code and templates. Each application follows the Golden Path conventions defined by the platform.

**Owner**: Application teams / Developers

**Why it exists**: This is where developers write actual service code. The platform provides deployment, observability, secret management, and security scanning — developers focus on business logic.

**Golden Path**: Every service should have:
- `backend/` — NestJS microservice with OpenTelemetry, structured logging, `/health`, `/metrics`
- `ui/` — (optional) Frontend dashboard
- Standard tooling: ESLint, Jest, multi-stage Dockerfile, non-root user

Services deployed from this directory follow the CI pipeline → ArgoCD → GKE flow automatically.

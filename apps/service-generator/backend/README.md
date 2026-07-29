# Service Generator - Backend

Example NestJS microservice demonstrating the Golden Path standards expected of every service on the platform.

## What it demonstrates

| Feature | Implementation |
|---------|---------------|
| OpenTelemetry | Auto-instrumentation of HTTP, gRPC, database calls |
| Structured logging | JSON via pino, request-scoped via nestjs-pino |
| Health checks | `/health` endpoint → Kubernetes liveness/readiness probes |
| Metrics | `/metrics` endpoint → Prometheus scraping |
| CI-ready | ESLint, Jest, multi-stage Dockerfile, non-root user |

## How it interacts with the platform

```
Secret Manager ──► External Secrets ──► K8s Secret ──► env var in this pod
OpenTelemetry ──► Collector ──► Tempo/Grafana
pino logs ──► stdout ──► Cloud Logging
/health ──► kubelet probe
/metrics ──► Prometheus
```

## Running locally

```bash
npm ci
npm run start:dev
# http://localhost:3000/health
# http://localhost:3000/metrics
```

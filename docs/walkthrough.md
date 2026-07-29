# Demo Walkthrough

This walkthrough demonstrates the complete Golden Path: from a developer writing code to the service running in production on GKE, deployed entirely via GitOps.

## Scenario

Alice, a backend developer at Acme Corp, needs to deploy a new microservice. In the old world, she'd file a Jira ticket, wait 3 days for the infrastructure team, manually configure Kubernetes manifests, and hope nothing breaks.

With the IDP, she does it herself in 15 minutes.

---

### Step 1: Scaffold the Service

Alice uses the Golden Path template to scaffold her service:

```
apps/
  my-service/
    backend/
      src/
        main.ts         # NestJS bootstrap with OTel + structured logging
        app.module.ts   # Pino logger module
        app.controller.ts  # /health, /metrics endpoints
        app.service.ts
        app.controller.spec.ts
      Dockerfile        # Multi-stage, non-root user, healthcheck
      package.json      # All dependencies pre-configured
      tsconfig.json
      nest-cli.json
```

The template already includes:
- OpenTelemetry instrumentation
- Structured JSON logging (pino)
- `/health` endpoint → Kubernetes liveness/readiness probes
- `/metrics` endpoint → Prometheus scraping
- Dockerfile with security best practices

---

### Step 2: Write Business Logic

Alice adds her business logic to `app.service.ts`:

```typescript
@Injectable()
export class AppService {
  getProducts() {
    return { items: [{ id: 1, name: 'Widget' }] };
  }
}
```

She commits and pushes:

```bash
git commit -m "feat: add products endpoint"
git push
```

---

### Step 3: CI Pipeline Runs

The GitHub Actions workflow triggers automatically:

```
1. Checkout          ✅
2. npm ci            ✅
3. ESLint            ✅  (no errors)
4. Unit tests        ✅  (5/5 passing)
5. Coverage          ✅  (87% line coverage)
6. Semgrep SAST      ✅  (no findings)
7. Gitleaks          ✅  (no secrets detected)
8. docker build      ✅  (123 MB)
9. Trivy scan        ✅  (0 critical, 0 high)
10. Push to AR       ✅  (us-central1-docker.pkg.dev/ldp21k-labs/devex-idp/my-service:abc123)
11. Update GitOps    ✅  (image tag updated in gitops/dev/my-service.yaml)
12. Commit + Push    ✅
```

The entire pipeline takes 4 minutes. Alice never touched kubectl or a Kubernetes manifest.

---

### Step 4: ArgoCD Reconciles

ArgoCD detects the new commit in the GitOps repo:

```
ArgoCD:
  → gitops/dev/my-service.yaml changed
  → Diff shows image tag: latest → abc123
  → Sync → apply Deployment, Service, HPA
  → Health check: Healthy ✅
```

Within 2 minutes of the CI pipeline finishing, `my-service` is live in the dev namespace.

---

### Step 5: Validate in Dev

Alice checks the service:

```bash
curl https://my-service.dev.acmecorp.com/health
# {"status":"healthy","timestamp":"2025-01-15T10:30:00Z","uptime":120}

curl https://my-service.dev.acmecorp.com/metrics
# {"uptime":120,"memory":{"rss":52428800},"cpu":{"user":10000,"system":5000}}
```

She can see the traces in Grafana Tempo (connected via OpenTelemetry) and the structured logs in Cloud Logging.

---

### Step 6: Promote to Staging

Alice copies `gitops/dev/my-service.yaml` to `gitops/staging/` and adjusts:

```yaml
replicaCount: 2
environment:
  NODE_ENV: "staging"
```

She opens a PR to merge dev overlay into staging. The PR is auto-approved (staging promotion doesn't require manual review in this org).

ArgoCD reconciles the staging cluster. Service is live in staging.

---

### Step 7: Promote to Production

After integration tests pass in staging, Alice opens a PR to merge staging overlay into production:

```yaml
replicaCount: 3
environment:
  NODE_ENV: "production"
  LOG_LEVEL: "warn"
resources:
  requests:
    cpu: 500m
    memory: 512Mi
  limits:
    cpu: 1000m
    memory: 1024Mi
```

This PR requires approval from the platform team (CODEOWNERS, branch protection).

Once approved and merged, ArgoCD reconciles production. Service is live.

---

### Step 8: Observability

With the service in production:

- **Health**: ArgoCD dashboard shows all services green
- **Metrics**: Prometheus scrapes `/metrics` → Grafana dashboards show golden signals
- **Logs**: Structured JSON logs flow to Cloud Logging, queryable by trace ID
- **Traces**: OpenTelemetry traces show the full request waterfall across services

---

## Rollback

If something goes wrong:

```bash
git revert abc123  # The bad commit
git push
# ArgoCD detects the revert → reconciles → service rolls back
```

Rollback is a single Git operation. No kubectl, no SSH, no panic.

---

## Key Takeaways for Interviews

| Concept | Demonstrated |
|---------|-------------|
| **Self-service** | Developer deploys without a platform team ticket |
| **Everything as Code** | Infra (Terraform), platform (Helm/YAML), apps (Dockerfile) — all in Git |
| **CI ≠ CD** | CI builds & pushes; ArgoCD deploys. CI never touches the cluster |
| **Pull-based GitOps** | ArgoCD pulls desired state from Git; drift is auto-corrected |
| **Zero secrets in Git** | Secret Manager → External Secrets → K8s Secret → env var |
| **Golden Path** | One Helm chart + one CI workflow = every service consistent by default |

# Demo Flow

This document describes the end-to-end demo walkthrough — from a developer writing code to the application running in production on GKE.

## Prerequisites

- GCP project with GKE cluster provisioned (via Terraform in `infrastructure/`)
- GitOps controller (Flux/Argo CD) running in the cluster
- GitHub Actions configured with GCP workload identity federation
- Artifact Registry for container images

---

## Scenario: Deploy a New Microservice

A developer is tasked with creating a new `user-service` microservice.

### Step 1: Scaffold the Service (Developer)

The developer uses the Backstage scaffolder or a CLI template to bootstrap the new service:

```
Workload template generates:
  workloads/apps/user-service/
    base/
      kustomization.yaml
      deployment.yaml
      service.yaml
      hpa.yaml
    overlays/
      staging/
        kustomization.yaml
        ingress-patch.yaml
      production/
        kustomization.yaml
        ingress-patch.yaml
```

The template encodes best practices: resource limits, liveness/readiness probes, PodDisruptionBudget, HPA, and Workload Identity annotation.

### Step 2: Write and Push Code (Developer)

The developer writes the application logic and pushes to the source repository.

```
git add .
git commit -m "feat(user-service): initial implementation"
git push
```

### Step 3: CI Pipeline Executes (GitHub Actions)

The CI pipeline defined in `ci-cd/pipelines/` triggers on push:

```
1. Lint (golangci-lint, eslint, etc.)
2. Unit tests
3. Container build (Dockerfile → image tag)
4. Vulnerability scan (Trivy / Grype)
5. Push image to Artifact Registry (us-central1-docker.pkg.dev/<project>/<repo>/user-service:<sha>)
6. Clone the GitOps repository
7. Update the staging overlay with the new image tag
8. Open a PR against the GitOps repository
```

The CI pipeline never touches the cluster — it only updates the GitOps repo.

### Step 4: GitOps Reconciliation (Staging)

The GitOps controller detects the new commit in the GitOps repository:

```
Flux/Argo CD:
  1. Pulls the updated staging overlay
  2. Diffs desired state against live cluster state
  3. Applies changes — creates/updates Deployment, Service, Ingress
  4. Reports health status back to the GitOps repository (commit status)
```

Within ~2 minutes, `user-service` is live in staging with:
- Automatic TLS via cert-manager
- DNS via external-dns
- Metrics scraped by Prometheus
- Logs streamed to Loki
- Traces sampled via OpenTelemetry

### Step 5: Validate in Staging (Developer)

The developer validates the service in staging:

```
# Port-forward via Backstage or CLI
./scripts/dev-port-forward.sh user-service staging

# Check logs
kubectl logs -n staging -l app=user-service

# Check metrics
Open Grafana dashboard for user-service → verify 200 responses, low latency

# Run integration tests
Integration tests execute against the staging endpoint
```

### Step 6: Promote to Production (Developer)

Once validated, the developer promotes to production by merging the staging overlay changes into the production overlay:

```
PR: "promotion: user-service to production"
  - Copies staging overlay changes to production/
  - Adjusts replica count (1 → 3)
  - Adjusts resource limits (development → production sizing)
```

This PR requires approval from a platform engineer or senior developer (protected branch, CODEOWNERS).

### Step 7: GitOps Reconciliation (Production)

Same reconciliation loop as staging, now targeting the production cluster:

```
Flux/Argo CD:
  1. Detects commit to production overlay
  2. Reconciles production cluster
  3. user-service is live in production
```

### Step 8: Observe and Monitor

With the service live in production:

```
Grafana Dashboard: golden signals — latency, errors, traffic, saturation
Loki: structured log queries with automatic labels from OpenTelemetry
Tempo: trace waterfall for distributed request debugging
Alerts: Alertmanager rules trigger on error budget burn, high latency
```

---

## Rollback Flow

If a production issue is detected:

```
1. Developer identifies the bad commit in the GitOps repo
2. Runs: git revert <bad-commit> && git push
3. Opens PR for the revert
4. Merge → GitOps controller reconciles → service rolls back
```

Rollback is just a Git operation. No direct cluster access required.

---

## Key Demo Takeaways

| Principle | Demonstrated By |
|-----------|----------------|
| **Self-service** | Developer scaffolds a new service without a platform ticket |
| **Everything as Code** | Infrastructure, platform config, and app manifests — all in Git |
| **CI vs CD separation** | CI builds & pushes; GitOps deploys. CI never touches the cluster |
| **Auditable deployments** | Every change is a PR with review, approval, and revert capability |
| **Drift detection** | GitOps controller continuously reconciles — manual changes are reverted |
| **Golden paths** | Templates encode best practices so developers default to the right thing |

# Demo Flow

This document is designed for live portfolio demonstrations. Each step is timed and maps to a specific Platform Engineering concept.

## Pre-Demo Checklist

- [ ] GCP project accessible (`gcloud auth list`)
- [ ] Terraform initialized (`infrastructure/terraform/environments/lab/`)
- [ ] ArgoCD UI accessible (port-forward or load balancer)
- [ ] Artifact Registry has at least one image
- [ ] Terminal font size is large enough for screen sharing

## Demo Script (15 minutes)

### Phase 1: Architecture Overview (3 min)

**Show**: `docs/architecture.md` ASCII diagram

**Say**: "This is a layered Internal Developer Platform. Developers interact with Git. CI builds containers. ArgoCD deploys them. The platform provides shared services — secret management, observability, ingress. The infrastructure is provisioned with Terraform."

**Concept**: Platform Engineering abstracts infrastructure complexity.

---

### Phase 2: Repository Tour (2 min)

**Show**: File tree in IDE

**Say**: "The repository is organized by concern — infrastructure, platform, apps, GitOps. Each directory has a README explaining what it is, why it exists, and who owns it. This is important because in a real organization, different teams own different parts."

**Concept**: Clear ownership boundaries enable platform adoption.

---

### Phase 3: Infrastructure as Code (3 min)

**Show**: `infrastructure/terraform/modules/`

**Say**: "Five reusable modules provision the GCP foundation. Network, GKE Autopilot, Artifact Registry, IAM with Workload Identity, and Secret Manager. The lab environment wires them together. Running `terraform apply` creates everything needed for the platform."

**Run**: `terraform plan` in `infrastructure/terraform/environments/lab/`

**Concept**: Infrastructure as Code ensures reproducibility and auditability.

---

### Phase 4: CI Pipeline (2 min)

**Show**: `.github/workflows/ci.yml`

**Say**: "One reusable workflow for all services. Lint, test, SAST, build, Trivy scan, push to Artifact Registry, update GitOps. Note that CI never touches the cluster — it only writes to Git."

**Concept**: CI builds artifacts; CD deploys them. These are separate concerns.

---

### Phase 5: GitOps Deployment (3 min)

**Show**: ArgoCD UI

**Say**: "Here's the ArgoCD dashboard. This Application was deployed by simply adding a YAML file to the `gitops/dev/` directory. ArgoCD detected the change via Git webhook and reconciled the cluster. The service is healthy — all probes pass."

**Show**: `gitops/dev/service-generator.yaml`

**Say**: "This is the entire deployment definition. It references the Helm chart with environment-specific values. To promote to staging, I copy this file to `gitops/staging/` and adjust replicas from 1 to 2. Promotion is a Git operation."

**Concept**: Git is the single source of truth. Drift is auto-corrected.

---

### Phase 6: Runtime Validation (2 min)

**Show**: `curl /health` and `curl /metrics`

**Say**: "Every service exposes `/health` and `/metrics`. Kubernetes uses health for liveness and readiness probes. Prometheus scrapes metrics. Structured JSON logs go to Cloud Logging. OpenTelemetry traces go to Tempo."

**Show**: Structured log output

**Concept**: Golden Path services get observability for free — they don't configure it, the Helm chart provides it.

---

## Live Demo Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| GKE cluster not ready | Terraform apply done before demo |
| ArgoCD not synced | Force sync before showing UI |
| Network issues | Have screenshots as backup |
| GCP quota exceeded | Have a second project ready |
| Container pull fails | Pre-pull image to cluster nodes |

## Screenshot Placeholders

Insert screenshots of:
- [ ] ArgoCD dashboard showing healthy application
- [ ] Grafana dashboard with golden signals
- [ ] Cloud Logging with structured log query
- [ ] GitHub Actions CI pipeline run
- [ ] Terraform plan output
- [ ] `kubectl get applications -n argocd`
- [ ] `curl /health` response
- [ ] Secret Manager console showing secrets

## GIF Placeholder

Insert a screen recording GIF showing:
1. Developer pushes code
2. GitHub Actions runs
3. ArgoCD auto-syncs
4. Service is live
5. Developer curls the endpoint

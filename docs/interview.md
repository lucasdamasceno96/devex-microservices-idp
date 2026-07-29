# Interview Preparation Guide

This document helps you use the `devex-microservices-idp` project in Platform Engineering interviews. Each section maps to common interview topics.

---

## Tell Me About This Project

**30-second pitch**:

> I built an Internal Developer Platform that abstracts GKE complexity behind a Git interface. Developers deploy to production by merging a PR. The platform provisions GCP infrastructure with Terraform, runs an Autopilot cluster, uses ArgoCD for GitOps, integrates Secret Manager via External Secrets, and enforces a Golden Path through a shared Helm chart and reusable CI workflow.

**Key numbers to mention**:

- **5 Terraform modules** — network, gke, artifact-registry, iam, secret-manager
- **3 environments** — dev, staging, production on one GKE cluster (namespace isolation)
- **1 reusable CI workflow** — all services use the same pipeline
- **0 kubectl commands for deployment** — everything is GitOps

---

## Common Interview Questions

### "Why GitOps instead of CI-driven deployment?"

GitOps (pull-based) solves credential sprawl — CI never needs cluster access. It also provides continuous reconciliation: if someone manually changes a deployment, ArgoCD reverts it within minutes. Every deployment is auditable as a Git commit. Rollback is `git revert`.

CI-driven deployment (push-based) requires CI to have cluster credentials, which is a security risk, and lacks drift detection.

### "Why Autopilot instead of Standard GKE?"

For this portfolio scope, Autopilot eliminates node management overhead. In production, I'd evaluate based on workload requirements — Autopilot for standard workloads, Standard for workloads needing daemonsets, GPU, or custom node configs.

### "How does Secret Manager integration work?"

The flow: GCP Secret Manager stores secrets → External Secrets Operator authenticates via Workload Identity → ESO syncs secrets into Kubernetes Secrets → Pods consume them via `envFrom`. Secrets never touch Git. Rotation is handled by ESO's refresh interval.

### "What's the Golden Path?"

The Golden Path is the paved road — the supported, recommended way to deploy a service. In this platform, it's: use the shared Helm chart, use the reusable CI workflow, deploy via GitOps. If a team follows the Golden Path, they get health checks, metrics, logging, tracing, HPA, and security scanning for free.

Teams *can* deviate (escape hatches), but they own the consequences — no platform team support for non-Golden-Path deployments.

### "How would this scale to 50 services?"

- **Monorepo → multi-repo**: Each service gets its own repo; GitOps repo remains separate
- **Helm chart versioning**: Platform team releases chart v1.1.0; teams opt in by bumping their chart version
- **ArgoCD App of Apps**: One root Application per environment manages all service Applications
- **Resource quotas + LimitRanges**: Namespace-level enforcement prevents noisy neighbors
- **Cluster-per-environment**: Separate GKE clusters for dev/staging/production instead of namespace isolation

### "What's missing for production readiness?"

- **OIDC authentication** for ArgoCD (currently relies on admin password)
- **Network policies** for micro-segmentation
- **PodSecurityPolicy / Pod Security Standards**
- **Backup** for Artifact Registry and cluster state
- **Disaster recovery** plan and runbooks
- **SLI/SLO definition** for platform services
- **Cost allocation** labels on all resources

---

## Technical Deep-Dive Topics

### Terraform State Management

State is stored remotely in GCS (`gs://ldp21k-labs-tfstate/all`) with versioning enabled. This prevents state file conflicts in team environments and provides an audit trail of infrastructure changes. The bucket was bootstrapped manually — Terraform shouldn't manage its own state backend (chicken-and-egg problem).

### Workload Identity

GKE Workload Identity maps Kubernetes ServiceAccounts to GCP IAM ServiceAccounts. This eliminates static keys:

```
K8s SA "flux" (in namespace "flux-system")
  ↓ annotation: iam.gke.io/gcp-service-account: devex-idp-gitops@PROJECT.iam.gserviceaccount.com
GCP SA "devex-idp-gitops"
  ↓ roles/artifactregistry.reader
Artifact Registry (pull images)
```

The binding uses `roles/iam.workloadIdentityUser` on the GCP SA, which tells IAM "this K8s SA can impersonate this GCP SA."

### ArgoCD App of Apps

The root Application (`root-app.yaml`) is the bootstrap. It points to the GitOps directory for an environment. ArgoCD recursively discovers all other Applications in that directory and deploys them.

This means adding a new service to dev is a single file: `gitops/dev/new-service.yaml`. No ArgoCD CLI, no UI interaction.

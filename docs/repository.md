# Repository Structure

Every directory in this repository exists to teach a Platform Engineering concept. This document explains why each folder exists, which team owns it, and how it interacts with the rest of the platform.

## `apps/`

**Why it exists**: Contains application source code. In a larger organization, apps would live in separate repositories — here they co-exist for portfolio clarity.

**Problem it solves**: Developers need a place to write actual service code. This is where the CI pipeline looks for `Dockerfile` and `package.json`.

**Who owns it**: Application teams / developers.

**Platform interaction**: CI reads `apps/<service>/` to build containers. GitOps references `apps/` for nothing — it only cares about the Helm chart and image tag.

---

## `infrastructure/`

**Why it exists**: Terraform modules and environment definitions for GCP resources. This is the foundation everything else runs on.

**Problem it solves**: Without IaC, infrastructure drifts, environments differ, and onboarding takes weeks. Terraform ensures every environment is identical and reproducible.

**Who owns it**: Platform Engineering team.

**Platform interaction**: Terraform provisions VPC, GKE, Artifact Registry, IAM, and Secret Manager. The Kubernetes cluster created here runs all platform components and workloads.

**Enterprise best practice**: Remote state in GCS with versioning and locking. Modules are environment-agnostic — `environments/lab/` wires them together with env-specific values.

---

## `platform/`

**Why it exists**: Kubernetes-native components that form the platform itself — ArgoCD, External Secrets, and the Golden Path Helm chart.

**Problem it solves**: Without these, every team would install their own ingress, their own secret management, their own deployment tool. The platform provides these as shared services.

**Who owns it**: Platform Engineering team.

**Sub-components**:

| Directory | Purpose |
|-----------|---------|
| `argocd/` | GitOps controller — the single entity with cluster write access |
| `external-secrets/` | Syncs GCP Secret Manager secrets into Kubernetes Secrets |
| `helm-chart/` | The Golden Path template — every service uses this same chart |

**Enterprise best practice**: Platform components are themselves deployed via GitOps. No manual `helm install` after initial bootstrap.

---

## `services/`

**Why it exists**: Reserved for service-specific Kubernetes manifests or Kustomize overlays that override the shared Helm chart defaults.

**Problem it solves**: 95% of services use the Golden Path chart as-is. The 5% that need customizations put their patches here, keeping the chart simple and the overrides explicit.

**Who owns it**: Application teams, reviewed by Platform Engineering.

**Platform interaction**: GitOps directory references services here when deploying. If empty, services use the Helm chart directly from `platform/helm-chart/`.

---

## `gitops/`

**Why it exists**: The single source of truth for what runs in each environment. ArgoCD watches this directory and continuously reconciles.

**Problem it solves**: Without GitOps, you don't know what's running where without checking each cluster. With GitOps, the answer is always "whatever is in the `gitops/` directory on the `main` branch."

**Who owns it**: Platform Engineering (structure) + Application teams (service definitions).

**Sub-components**:

| Directory | Purpose | Promotion Trigger |
|-----------|---------|-------------------|
| `dev/` | Development environment | Auto-deploy on PR merge |
| `staging/` | Pre-production validation | Auto-deploy on PR merge |
| `production/` | Live workloads | Manual PR approval required |

**Enterprise best practice**: Promotion is a Git PR from one environment overlay to another. Rollback is `git revert`.

---

## `.github/workflows/`

**Why it exists**: One reusable CI workflow shared by all services. Every service triggers the same pipeline — lint, test, SAST, build, scan, push, update GitOps.

**Problem it solves**: Duplicated CI pipelines lead to inconsistent quality gates. A single workflow means updating it once improves every service.

**Who owns it**: Platform Engineering.

**Platform interaction**: The workflow's final step updates the GitOps repo with the new image tag. CI never touches the cluster directly.

---

## `scripts/`

**Why it exists**: Automation scripts for platform operators — bootstrap, deploy, destroy, validate.

**Problem it solves**: Reduces complex multi-step processes to single commands. `./deploy.sh` provisions everything from scratch.

**Who owns it**: Platform Engineering.

---

## `docs/`

**Why it exists**: Comprehensive documentation that teaches Platform Engineering concepts, not just describes files.

**Problem it solves**: Good documentation reduces onboarding time from weeks to hours. Each doc targets a different audience (developer, interviewer, operator).

**Who owns it**: Platform Engineering (with contributions from all teams).

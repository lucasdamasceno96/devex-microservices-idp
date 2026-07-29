# Platform

Kubernetes-native components that form the Internal Developer Platform. These are not applications — they are the shared services that every application team depends on.

**Owner**: Platform Engineering

**Why it exists**: Without a platform layer, every team installs their own ingress controller, their own secret management, their own CI/CD. The platform provides these as managed, shared services so teams focus on business logic.

**What problem it solves**: Reduces cognitive load on developers. When a developer follows the Golden Path, they get observability, secret management, and GitOps deployment without configuring any of it.

## Components

| Component | Location | Purpose |
|-----------|----------|---------|
| **ArgoCD** | `argocd/` | GitOps controller — the only entity with cluster write access |
| **External Secrets** | `external-secrets/` | Syncs GCP Secret Manager → Kubernetes Secrets |
| **Helm Chart** | `helm-chart/` | Golden Path template — every service uses this chart |

## Enterprise pattern

Platform components are themselves deployed via GitOps. After initial bootstrap (one `kubectl apply` for ArgoCD), all platform changes happen through Git:
1. Update the manifest in this directory
2. ArgoCD detects the change
3. ArgoCD reconciles itself (self-managed GitOps)

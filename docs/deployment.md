# Deployment Guide

## Prerequisites

- Google Cloud SDK (`gcloud`) installed and authenticated
- Terraform >= 1.5
- `kubectl` installed
- `helm` installed
- Access to GCS bucket `ldp21k-labs-tfstate`

## Architecture Overview

```
./bootstrap.sh    # One-time: enable APIs, create state bucket
./deploy.sh       # Everything: infra → cluster → platform → ready
./validate.sh     # Health check
./destroy.sh      # Tear down everything
```

## Quick Start

```bash
# 1. Bootstrap the GCP project (one-time)
export GCP_PROJECT_ID="ldp21k-labs"
./scripts/bootstrap.sh

# 2. Deploy the full platform
./scripts/deploy.sh

# 3. Validate
./scripts/validate.sh
```

## What Gets Deployed

| Resource | Provider | Details |
|----------|----------|---------|
| VPC + subnet + Cloud NAT | Terraform | `10.0.0.0/20`, private Google access |
| GKE Autopilot cluster | Terraform | Private nodes, REGULAR release channel |
| Artifact Registry (Docker) | Terraform | `us-central1-docker.pkg.dev/ldp21k-labs/devex-idp` |
| IAM (Workload Identity) | Terraform | GitOps SA + External Secrets SA |
| Secret Manager | Terraform | Two secrets for shared platform config |
| ArgoCD | Manifest | GitOps controller |
| External Secrets Operator | Helm | GCP Secret Manager → K8s Secrets |

## Deploying a Service

After the platform is running:

```bash
# 1. Apply the root ArgoCD app for the target environment
kubectl apply -f gitops/dev/root-app.yaml

# 2. The service-generator is automatically deployed via GitOps

# 3. Check ArgoCD sync status
kubectl port-forward -n argocd svc/argocd-server 8080:443
# Open https://localhost:8080 — user: admin, password: see deploy output
```

## CI/CD Flow

```
Developer pushes code → GitHub Actions workflow
  → lint → test → SAST → build → Trivy scan → push to Artifact Registry
  → update GitOps repo with new image tag
  → ArgoCD detects change → reconciles cluster
  → Service live in target environment
```

## Environment Promotion

```
dev (auto-deploy on merge to main)
  │
  ▼
staging (copy dev ArgoCD app with adjusted values)
  │
  ▼  (requires PR approval)
production (copy staging ArgoCD app with hardened values)
```

## Cleanup

```bash
./scripts/destroy.sh
```

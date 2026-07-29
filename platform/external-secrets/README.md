# External Secrets Operator

ESO syncs secrets from GCP Secret Manager into Kubernetes Secrets. Workloads never touch Secret Manager directly — they consume standard Kubernetes Secrets.

## Why External Secrets?

- **Separation of concerns**: Secret storage (GCP) ≠ secret consumption (K8s)
- **No secret in Git**: Secrets never touch the GitOps repo
- **Automatic rotation**: Secrets are refreshed on a configurable interval
- **Workload Identity**: ESO authenticates to GCP using Workload Identity — no static keys

## Architecture

```
GCP Secret Manager
       │
       ▼
External Secrets Operator (GCP SA + Workload Identity)
       │
       ▼
Kubernetes Secret
       │
       ▼
NestJS pod (envFrom / volume mount)
```

## Installation

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets \
  -n external-secrets --create-namespace \
  --set serviceAccount.annotations."iam\.gke\.io/gcp-service-account"=devex-idp-ext-secrets@PROJECT.iam.gserviceaccount.com
```

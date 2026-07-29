# Workloads

Application workloads running on the platform. Each application is defined declaratively and deployed via GitOps.

## Structure

| Directory | Responsibility |
|-----------|---------------|
| `templates/` | Workload blueprints and scaffold definitions used to bootstrap new services |
| `apps/` | Individual application definitions — Kubernetes manifests, Kustomize overlays, Helm values |

## Convention

Each application follows the pattern:

```
apps/<app-name>/
  base/
    kustomization.yaml
    deployment.yaml
    service.yaml
  overlays/
    staging/
    production/
```

Applications declare their desired state; the platform reconciles it. No `kubectl apply` from CI — only Git writes to the cluster.

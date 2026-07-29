# GitOps

Environment-specific overlays defining what runs in each cluster. The single source of truth for the deployed state. A GitOps controller (Flux/Argo CD) running inside the cluster continuously reconciles this repository against the live cluster.

## Structure

| Directory | Responsibility |
|-----------|---------------|
| `staging/` | Staging environment overlay — development-grade configuration |
| `production/` | Production environment overlay — hardened configuration |

## Promotion Flow

```
Developer merges PR → CI builds & publishes artifact → CI opens PR updating staging overlay
  → GitOps reconciles staging cluster
  → Developer validates in staging
  → Developer opens PR merging staging overlay into production overlay
  → GitOps reconciles production cluster
```

No manual `kubectl`. No CI-to-cluster access. Git is the control plane.

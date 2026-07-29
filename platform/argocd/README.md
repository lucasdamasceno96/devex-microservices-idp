# ArgoCD - GitOps Controller

ArgoCD is the GitOps controller that reconciles the desired state defined in the `gitops/` directory with the live Kubernetes cluster.

## Why ArgoCD?

- **Declarative**: Cluster state is defined in Git, not applied via CLI
- **Self-healing**: Continuously reconciles — any manual drift is automatically corrected
- **Auditable**: Every deployment is a Git commit, every rollback is a revert
- **Multi-cluster**: One ArgoCD instance can manage multiple clusters and environments

## Installation

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## App of Apps Pattern

The root application bootstraps all other applications:

```
argocd/
  root-app.yaml        # Points to gitops/dev, staging, production
```

Each environment defines which services run there and with what configuration.

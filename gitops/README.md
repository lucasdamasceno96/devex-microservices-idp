# GitOps

The single source of truth for what runs in each environment. ArgoCD watches this directory and continuously reconciles the live cluster against the desired state defined here.

**Owner**: Platform Engineering (structure) + Application teams (service definitions)

**Why it exists**: Without GitOps, you have configuration drift — nobody knows what's actually running where. The cluster state diverges from what's documented. Troubleshooting starts with "who applied what when?"

With GitOps, the answer is always: "Exactly what's in the `gitops/` directory on the `main` branch." Every change is a PR. Every deployment is auditable. Every rollback is `git revert`.

**What problem it solves**:
- **Auditability**: Git history = deployment history
- **Drift detection**: ArgoCD continuously reconciles — manual changes are automatically reverted
- **Disaster recovery**: Point ArgoCD at the GitOps repo → cluster is rebuilt
- **Review + Approval**: Protected branches enforce PR reviews for production changes

## Environments

| Environment | Purpose | Deployment Trigger |
|-------------|---------|-------------------|
| `dev/` | Rapid iteration, feature testing | Auto-deploy on merge |
| `staging/` | Integration testing, pre-prod validation | Auto-deploy on merge |
| `production/` | Live user traffic | Manual PR approval required |

## How promotion works

Promotion is a Git PR from one environment overlay to another:

```
dev/service-generator.yaml  ──copy──►  staging/service-generator.yaml  ──PR──►  production/service-generator.yaml
```

Values change per environment (replicas, resources, log level). The Helm chart stays the same.

## Enterprise pattern

The root Application (`root-app.yaml`) bootstraps the environment. It points ArgoCD at the environment directory. ArgoCD recursively discovers all Applications in that directory — the "App of Apps" pattern.

Adding a service to dev is as simple as creating `gitops/dev/<service-name>.yaml`.

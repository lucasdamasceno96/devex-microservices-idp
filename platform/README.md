# Platform

Kubernetes-native platform components deployed via GitOps (Flux/Argo CD). These provide the shared foundation every workload depends on — observability, ingress, security, and service catalog.

## Structure

| Directory | Responsibility |
|-----------|---------------|
| `base/` | Cluster-wide configuration — namespaces, RBAC, resource quotas |
| `ingress/` | Ingress controllers, cert-manager, external-dns |
| `observability/` | Prometheus, Grafana, Loki, Tempo, OpenTelemetry collector |
| `security/` | Policy engines (OPA/Kyverno), network policies, pod security |
| `service-catalog/` | Self-service definitions (Crossplane/Backstage templates) |
| `secrets/` | External Secrets Operator, Vault integration |

## Design Principle

Platform components are deployed and managed via GitOps. Changes to any component require a PR against this repository; the GitOps controller reconciles the desired state into the cluster automatically.

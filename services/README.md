# Services

Reserved for service-specific Kubernetes customizations that extend the shared Helm chart.

**Owner**: Application teams (reviewed by Platform Engineering)

**Why it exists**: The shared Helm chart in `platform/helm-chart/` covers 95% of use cases. Some services need custom behaviors (Ingress, ServiceAccount, NetworkPolicy, etc.) that don't belong in the shared chart. Those customizations live here.

**When to use**: Only when the Helm chart values cannot express the needed configuration. Before adding a service-specific manifest, ask: "Can this be a Helm value instead?"

## Structure (future)

```
services/
  my-service/
    ingress.yaml
    network-policy.yaml
    service-monitor.yaml
```

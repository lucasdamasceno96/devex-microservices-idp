# Platform Architecture

## High-Level Design

The platform follows a layered architecture where each layer builds on top of the one below it. The guiding principle is **everything-as-code, reconciled via Git**.

```
┌─────────────────────────────────────────────────────────┐
│                    Developer Experience                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ Backstage│  │    CLI   │  │ Templates│              │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘              │
│       └──────────────┼─────────────┘                    │
│                      │ PR to GitOps repo                │
├──────────────────────┼──────────────────────────────────┤
│               GitOps Layer                              │
│  ┌───────────────────┴──────────────────┐              │
│  │  Flux CD / Argo CD                   │              │
│  │  Watches gitops/ directories         │              │
│  │  Reconciles desired → actual state   │              │
│  └───────────────────┬──────────────────┘              │
│                      │                                  │
├──────────────────────┼──────────────────────────────────┤
│               Platform Layer (GKE)                       │
│  ┌───────────────────┴──────────────────┐              │
│  │  Ingress  │ Observability │ Security │              │
│  │  cert-    │ Prometheus    │ OPA/     │              │
│  │  manager  │ Grafana       │ Kyverno  │              │
│  │  external-│ Loki/Tempo    │ net-pol  │              │
│  │  dns      │ OTEL          │ WI       │              │
│  └───────────────────┬──────────────────┘              │
│                      │                                  │
├──────────────────────┼──────────────────────────────────┤
│               Infrastructure Layer (GCP)                 │
│  ┌───────────────────┴──────────────────┐              │
│  │  VPC    │  GKE   │  GCS   │  IAM    │              │
│  │  Subnet │  Node  │  Arti- │  Work-  │              │
│  │  NAT    │  Pools │  fact  │  load   │              │
│  │  FW     │        │  Reg.  │  ID     │              │
│  └───────────────────┴────────┴────────┘              │
└─────────────────────────────────────────────────────────┘
```

## Layer Responsibilities

### 1. Infrastructure Layer (Terraform)

- Provisions all GCP resources: project, VPC, GKE, IAM, service accounts
- State stored remotely in GCS with versioning and locking
- Organized in dependency order: bootstrap → networking → GKE
- Reusable modules for consistent resource patterns

### 2. Platform Layer (Kubernetes + GitOps)

- Deployed via GitOps — the GitOps controller is the only entity with write access to the cluster
- Provides shared services every workload needs:
  - **Ingress**: Istio / NGINX ingress, cert-manager for automatic TLS, external-dns for DNS records
  - **Observability**: Prometheus for metrics, Grafana for dashboards, Loki for logs, Tempo for traces, OpenTelemetry collector for telemetry pipelines
  - **Security**: OPA/Gatekeeper or Kyverno for policy enforcement, NetworkPolicies for micro-segmentation, Workload Identity for GCP service account mapping
  - **Secrets**: External Secrets Operator to sync secrets from GCP Secret Manager into Kubernetes

### 3. Workload Layer

- Application manifests stored in `workloads/apps/<name>/`
- Each app declares what it needs (CPU, memory, ingress rules, secrets)
- Platform policies validate and enforce constraints
- CI never touches the cluster — it only updates the GitOps repo with new image tags

### 4. Developer Experience Layer

- **Backstage**: Developer portal as the single pane of glass — service catalog, tech docs, scaffolder for bootstrapping new services
- **CLI**: Lightweight CLI for common developer operations (port-forward, logs, scaffold)
- **Templates**: Golden path templates that encode best practices for new services

## Environment Strategy

| Environment | Purpose | Promotion Trigger |
|-------------|---------|-------------------|
| **Staging** | Pre-production validation | Auto-deploy on merge to `main` |
| **Production** | Live workload | Manual PR from staging overlay to production overlay |

## Key Design Decisions

See [decisions.md](decisions.md) for the rationale behind each architectural choice.

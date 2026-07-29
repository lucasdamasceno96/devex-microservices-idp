# Architectural Decisions

This document records the key architectural decisions, the context in which they were made, the available alternatives, and the rationale for the chosen approach.

## ADR-001: GitOps as the Deployment Mechanism

**Status**: Accepted

**Context**: The platform needs a reliable, auditable, and reproducible mechanism to deploy platform components and workloads to GKE clusters.

**Decision**: Use GitOps (Flux CD or Argo CD) as the sole mechanism for applying state to Kubernetes clusters. The Git repository is the single source of truth; the GitOps controller reconciles desired state into the live cluster.

**Alternatives Considered**:
- **CI-driven deployments** (`kubectl apply` from GitHub Actions): Risks credential sprawl, hard to audit, CI becomes a bottleneck.
- **Terraform Kubernetes provider**: Mixes infrastructure provisioning with workload management; slower reconciliation loop.

**Rationale**: GitOps decouples CI (build & push artifacts) from CD (deploy). It provides a continuous reconciliation loop, automatic drift detection, and a complete audit trail via Git history. Every change is a PR — reviewable, revertible, and observable.

---

## ADR-002: Terraform for GCP Infrastructure

**Status**: Accepted

**Context**: All GCP resources (project, VPC, GKE, IAM, service accounts) must be provisioned repeatably across environments.

**Decision**: Use Terraform with remote state stored in a versioned, encrypted GCS bucket. Organize Terraform code in layers (bootstrap → networking → GKE) to manage dependencies explicitly.

**Alternatives Considered**:
- **Pulumi**: More flexible (general-purpose languages) but smaller community and fewer GCP modules.
- **Google Cloud Deployment Manager**: GCP-native but limited ecosystem, harder to modularize.
- **ClickOps (Console)**: Non-reproducible, error-prone, impossible to audit.

**Rationale**: Terraform is the de facto standard for multi-cloud IaC, has a mature GCP provider, and supports modular composition via reusable modules. Layered organization prevents circular dependencies and enables partial updates.

---

## ADR-003: GKE as the Kubernetes Runtime

**Status**: Accepted

**Context**: The platform runs containerized microservices and requires a managed Kubernetes offering on GCP.

**Decision**: Use Google Kubernetes Engine (GKE) with Workload Identity, GCS FUSE CSI driver for storage, and separate node pools for system and workload components.

**Alternatives Considered**:
- **Cloud Run**: Excellent for simple services but limited for complex networking, multi-container pods, and custom scheduling.
- **Self-managed Kubernetes on GCE**: Full control but significantly higher operational overhead.
- **GKE Autopilot**: Attractive for reduced node management but less control over node configuration and daemonsets.

**Rationale**: GKE provides a managed control plane with zero-cost management, tight IAM integration via Workload Identity, and automatic upgrades. Standard node pools retain enough control for platform components (e.g., ingress controllers, observability agents) while keeping operational burden low.

---

## ADR-004: Separate Repositories for Infrastructure and Workloads

**Status**: Accepted

**Context**: The platform spans multiple concerns — infrastructure provisioning, platform components, and application workloads. Grouping everything in one repository creates coupling and slows iteration.

**Decision**: Maintain separate repositories:
- **devex-microservices-idp-infra**: Terraform infrastructure provisioning
- **devex-microservices-idp-platform**: Platform components (ingress, observability, security)
- **devex-microservices-idp-workloads**: Application workload definitions
- **devex-microservices-idp**: (this repo) Documentation, architecture, and cross-cutting concerns

**Note**: For the proof-of-concept phase, all concerns are co-located in the monorepo structure under `infrastructure/`, `platform/`, and `workloads/`. The separation into dedicated repos is a production hardening step.

**Alternatives Considered**:
- **True monorepo**: Simpler initially but becomes a bottleneck as team and service count grow — every commit triggers full CI, access control is coarse.
- **One repo per microservice**: Maximum isolation but difficult to enforce cross-cutting policies and version platform components consistently.

**Rationale**: Repo-per-concern balances autonomy with governance. Infrastructure changes don't trigger workload builds, platform components can be versioned independently, and access control can be scoped per repository.

---

## ADR-005: Staging and Production as GitOps Overlays

**Status**: Accepted

**Context**: The same set of workloads must run in staging and production with environment-specific configuration differences (replica count, resource limits, domain names).

**Decision**: Use Kustomize overlays within the GitOps repository. A `base/` directory defines common configuration; `staging/` and `production/` overlays patch environment-specific values.

**Alternatives Considered**:
- **Separate branches per environment**: GitOps controllers typically watch a single branch; branch-per-environment complicates configuration and promotes drift.
- **Helm with separate values files**: Viable but Kustomize is native to `kubectl`, simpler for patching, and better integrated with GitOps controllers.
- **Separate repositories per environment**: Overkill for two environments; adds unnecessary synchronization overhead.

**Rationale**: Kustomize overlays keep configuration DRY (Don't Repeat Yourself) while enabling environment-specific customization. Promotion is a PR from one overlay to another — simple, auditable, and reversible.

---

## ADR-006: Workload Identity for GCP Service Account Mapping

**Status**: Accepted

**Context**: Workloads running on GKE need access to GCP services (GCS, Pub/Sub, Secret Manager) without managing long-lived credentials.

**Decision**: Use GKE Workload Identity to map Kubernetes service accounts to GCP IAM service accounts. Each workload gets a dedicated Kubernetes SA bound to a GCP SA with the minimum required permissions.

**Alternatives Considered**:
- **Static service account keys**: Security risk — keys can leak, must be rotated manually, no built-in audit.
- **Instance-level service accounts** (Compute Engine default SA): Couples workloads to node identity; impossible to scope per-workload permissions.

**Rationale**: Workload Identity eliminates credential management. Permissions are scoped per workload via Kubernetes SA → GCP SA binding. Tokens are short-lived and automatically rotated by the GKE metadata server.

---

## ADR-007: OpenTelemetry for Observability Pipeline

**Status**: Accepted

**Context**: The platform needs a unified observability pipeline covering metrics, logs, and traces across all services, without vendor lock-in.

**Decision**: Use OpenTelemetry as the instrumentation and collection layer. Deploy the OpenTelemetry Collector as a DaemonSet (for node-level telemetry) and as a Deployment (for cluster-level aggregation). Export to Prometheus (metrics), Loki (logs), and Tempo (traces).

**Alternatives Considered**:
- **Vendor-specific agents** (Datadog, New Relic): Simpler setup but proprietary, costly, and constrain future migration.
- **Prometheus-only**: Great for metrics, limited for logs and traces.

**Rationale**: OpenTelemetry is the CNCF standard for observability. It provides SDKs for automatic instrumentation, a vendor-neutral collector, and export flexibility. Once instrumented, the backend can be swapped without code changes.

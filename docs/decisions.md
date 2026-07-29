# Architectural Decisions

## ADR-001: GitOps over Push-based CD

**Decision**: Use ArgoCD (pull-based GitOps) instead of CI-driven `kubectl apply`.

**Rationale**:
- CI never needs cluster credentials — eliminates credential sprawl
- Continuous reconciliation detects and corrects manual drift
- Every deployment is a Git commit — fully auditable and revertible
- Rollback is `git revert`

**Trade-off**: Slightly higher latency between image push and deployment (reconciliation interval). Mitigated by webhook triggers.

---

## ADR-002: GKE Autopilot over Standard

**Decision**: Use GKE Autopilot for the lab environment.

**Rationale**:
- Google manages nodes, scaling, and upgrades — zero node operations
- Pay-per-pod pricing fits lab/portfolio use
- Built-in security hardening (Shielded Nodes, workload identity)
- Autopilot enforces best practices by only allowing compliant workloads

**Trade-off**: Less node-level customization. Acceptable for portfolio scope.

---

## ADR-003: Helm Chart for Service Templates

**Decision**: Use a shared Helm chart as the Golden Path template instead of raw manifests or Kustomize.

**Rationale**:
- Single chart encodes all best practices (probes, HPA, resource limits, OTel, ESO)
- Environment-specific values via ArgoCD Application `values` field
- Chart versioning enables gradual rollout of platform changes
- `helm template` works without Tiller/server-side component

---

## ADR-004: External Secrets Operator over CSI Driver

**Decision**: Use External Secrets Operator (ESO) instead of Secrets Store CSI Driver for GCP Secret Manager integration.

**Rationale**:
- ESO creates native Kubernetes Secrets — compatible with envFrom/volume mounts
- Works with Helm chart `envFrom` without pod spec changes
- Supports refresh intervals and multi-tenancy
- CSI Driver is lower-level and better suited for volume-mount use cases

---

## ADR-005: Reusable GitHub Actions Workflow over Per-Service Copies

**Decision**: One `workflow_call` workflow reused by all services.

**Rationale**:
- Single source of truth for the CI pipeline definition
- Updating the workflow updates every service automatically
- Services declare only a thin trigger file that points to the shared workflow
- Aligns with the Golden Path philosophy

---

## ADR-006: Monorepo for Portfolio Scope

**Decision**: Single repository for infrastructure, platform, services, and GitOps.

**Rationale**:
- Simplifies portfolio demonstration — everything in one place
- No cross-repo coordination needed for a single-person project
- Clear separation via directory structure preserves logical boundaries
- Can be split into multi-repo when team grows

**Future evolution**: Split into `devex-idp-infra`, `devex-idp-platform`, and per-service repos.

---

## ADR-007: OpenTelemetry for Observability

**Decision**: Instrument services with OpenTelemetry for traces, with structured JSON logging (pino) and `/metrics` endpoints.

**Rationale**:
- OTel is the CNCF standard — vendor-neutral, future-proof
- Auto-instrumentation covers HTTP, gRPC, database calls with zero code changes
- Structured JSON logs enable machine parsing in Cloud Logging
- `/health` and `/metrics` endpoints enable Kubernetes-native probes and Prometheus scraping

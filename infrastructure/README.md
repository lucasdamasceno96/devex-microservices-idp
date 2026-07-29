# Infrastructure (Terraform)

Provisions the GCP foundation via Terraform using reusable modules. This is the bottom layer of the platform — everything else runs on top of what Terraform creates.

**Owner**: Platform Engineering

**Why it exists**: Without Infrastructure as Code, environments drift, changes are manual, and disaster recovery means rebuilding from memory. Terraform ensures every resource is defined declaratively, versioned, and reproducible.

## What it provisions

| Module | Resources |
|--------|-----------|
| `network` | VPC, subnet, Cloud NAT |
| `gke` | GKE Autopilot cluster (private) |
| `artifact-registry` | Docker container registry |
| `iam` | Service accounts + Workload Identity bindings |
| `secret-manager` | Platform shared secrets |

## How it interacts with the platform

1. Terraform provisions GKE → `kubectl` connects to cluster
2. ArgoCD installed on cluster → watches `gitops/` directory
3. External Secrets installed → reads `iam` module's SAs for Workload Identity
4. CI pipeline pushes images to Artifact Registry → GKE pulls from there

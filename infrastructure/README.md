# Infrastructure

GCP infrastructure provisioning via Terraform, organized as reusable modules consumed by environment-specific root modules.

## Structure

```
terraform/
├── modules/
│   ├── network/            # VPC, subnet, Cloud NAT
│   ├── gke/                # GKE Autopilot cluster (private)
│   ├── artifact-registry/  # Docker repository
│   ├── iam/                # Platform service accounts + Workload Identity
│   └── secret-manager/     # Shared platform secrets
├── environments/
│   └── lab/                # Single lab environment (root module)
└── policies/               # Organization policies and constraints
```

## Modules

| Module | Responsibility |
|--------|---------------|
| `network` | VPC, subnet, Cloud Router, Cloud NAT for private egress |
| `gke` | GKE Autopilot cluster with private nodes |
| `artifact-registry` | Docker repository for container images |
| `iam` | Service accounts and Workload Identity bindings for platform controllers |
| `secret-manager` | Secret Manager secrets for shared configuration |

## Usage

```bash
cd terraform/environments/lab

# Initialize (requires GCS bucket access)
terraform init

# Plan
terraform plan

# Apply
terraform apply
```

## State

Remote state is stored in `gs://ldp21k-labs-tfstate/all` with object versioning and locking enabled on the bucket.

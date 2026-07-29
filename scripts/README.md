# Scripts

Automation scripts that reduce complex multi-step operations to single commands.

**Owner**: Platform Engineering

**Why it exists**: Running the platform shouldn't require remembering 15 commands. Each script encapsulates a workflow into a single, documented, idempotent command.

## Scripts

| Script | Purpose |
|--------|---------|
| `bootstrap.sh` | One-time GCP project setup — enable APIs, create state bucket |
| `deploy.sh` | Full deployment — Terraform → kubectl → ArgoCD → External Secrets |
| `destroy.sh` | Tear down everything (requires confirmation) |
| `validate.sh` | Platform health check — validates every component |

## Usage

```bash
./scripts/bootstrap.sh   # One-time setup
./scripts/deploy.sh      # Deploy everything
./scripts/validate.sh    # Verify deployment
./scripts/destroy.sh     # Clean up
```

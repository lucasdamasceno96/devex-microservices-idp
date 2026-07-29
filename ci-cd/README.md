# CI/CD

Continuous Integration and Continuous Delivery pipeline definitions. Pipelines are responsible for building, testing, scanning, and pushing artifacts — never for deploying directly to clusters.

## Structure

| Directory | Responsibility |
|-----------|---------------|
| `pipelines/` | End-to-end pipeline definitions (GitHub Actions workflows) |
| `tasks/` | Reusable pipeline tasks — linting, testing, container build, vulnerability scan |

## Pipeline Philosophy

- **CI owns the artifact** — build, test, scan, push to registry
- **CD is GitOps** — update the GitOps repo with the new image tag; the GitOps controller handles deployment
- **Promotion** — staging auto-deploys on merge to main; production requires a PR from staging overlay to production overlay

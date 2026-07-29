# devex-microservices-idp

Internal Developer Platform (IDP) focused on Developer Experience — built on Google Cloud Platform, Kubernetes (GKE), and GitOps.

## Overview

This project demonstrates an enterprise-grade IDP that abstracts infrastructure complexity behind a self-service, GitOps-driven platform. Developers interact with the platform through Git — no direct cluster access, no manual infrastructure provisioning.

## Architecture Pillars

| Pillar | Technology |
|--------|-----------|
| **Cloud** | Google Cloud Platform |
| **Orchestration** | Google Kubernetes Engine (GKE) |
| **GitOps** | Flux CD / Argo CD |
| **Infrastructure as Code** | Terraform |
| **CI/CD** | GitHub Actions |
| **Observability** | Prometheus, Grafana, Loki, Tempo |
| **Service Catalog** | Backstage / Crossplane |

## Repository Structure

```
devex-microservices-idp/
├── docs/                    # Architecture, decisions, demo flow
├── infrastructure/          # Terraform — GCP provisioning (bootstrap → networking → GKE)
├── platform/                # Kubernetes-native platform components (ingress, observability, security)
├── workloads/               # Application workload definitions and templates
├── ci-cd/                   # CI/CD pipeline definitions (GitHub Actions)
├── gitops/                  # Environment overlays (staging, production)
└── scripts/                 # Utility and automation scripts
```

## Getting Started

See [docs/architecture.md](docs/architecture.md) for the full platform design.
See [docs/demo.md](docs/demo.md) for the end-to-end demo walkthrough.

## Portfolio Scope

This is a proof-of-concept portfolio project demonstrating:

- Platform Engineering best practices
- Infrastructure-as-Code with Terraform and state management
- GitOps-based continuous delivery on Kubernetes
- Self-service developer workflows
- Observability, security, and policy enforcement at the platform layer

# Architecture

## Problem

Developer teams at growing organizations face friction: waiting days for infrastructure tickets, inconsistent deployment patterns, manual credential management, and no visibility into what's running where. The result is slow delivery, configuration drift, and security gaps.

This platform solves these problems by treating infrastructure as a product — a self-service Internal Developer Platform that abstracts GCP/GKE complexity behind a Git-based interface.

## Layered Architecture

```
┌──────────────────────────────────────────────────────┐
│                Developer Experience                   │
│  Git PR  ──►  CI builds image  ──►  GitOps deploys   │
│  No kubectl. No Terraform. No tickets.               │
├──────────────────────────────────────────────────────┤
│                   Platform Layer                      │
│  ┌──────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │  ArgoCD  │  │ External Secrets │  │ Helm Charts │ │
│  │  GitOps  │  │ GCP → K8s sync  │  │ Golden Path │ │
│  └──────────┘  └─────────────────┘  └─────────────┘ │
├──────────────────────────────────────────────────────┤
│                  GKE (Autopilot)                      │
│  Dev │ Staging │ Production                           │
│  Namespace isolation with resource quotas             │
├──────────────────────────────────────────────────────┤
│                  GCP Foundation                       │
│  VPC  │  IAM  │  Artifact Registry  │  Secret Manager │
└──────────────────────────────────────────────────────┘
```

## Golden Path

The Golden Path is the paved road that makes the right thing the easy thing:

1. **Developer** writes code and opens a PR
2. **CI pipeline** (reusable GitHub Actions workflow) runs lint → test → SAST → build → scan → push
3. **CI updates** the GitOps repo with the new image tag
4. **ArgoCD** detects the change and reconciles the Kubernetes cluster
5. **Service is live** — with health checks, metrics, structured logging, and OpenTelemetry traces

Every service follows this same path. No snowflakes.

## Component Interaction

```
Developer pushes code
       │
       ▼
   GitHub Actions (CI)
       │
       ├──► Artifact Registry (image push)
       │
       └──► GitOps Repo (image tag update)
                │
                ▼
            ArgoCD (GitOps controller)
                │
                ▼
         GKE Workload
                │
                ├──► External Secrets Operator ──► Secret Manager
                ├──► OpenTelemetry ──► Collector ──► Grafana/Tempo
                └──► Structured Logs ──► stdout ──► Cloud Logging
```

## Key Design Principles

| Principle | Implementation |
|-----------|---------------|
| **Git as single source of truth** | All cluster state in GitOps repo; no kubectl apply |
| **Pull-based deployment** | ArgoCD pulls desired state from Git, reconciles continuously |
| **CI ≠ CD** | CI builds & pushes artifacts; CD is GitOps reconciliation |
| **Least privilege** | Workload Identity maps per-workload K8s SA → minimum GCP IAM |
| **Secrets never touch Git** | External Secrets syncs GCP Secret Manager → K8s Secrets at runtime |
| **Golden Path by default** | Reusable Helm chart + CI workflow = correct setup with zero effort |

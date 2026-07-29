# ── Network ──

output "vpc_name" {
  description = "VPC network name"
  value       = module.network.network_name
}

output "subnet_name" {
  description = "Subnet name"
  value       = module.network.subnet_name
}

# ── GKE ──

output "cluster_name" {
  description = "GKE cluster name"
  value       = module.gke.cluster_name
}

output "cluster_location" {
  description = "GKE cluster region"
  value       = module.gke.cluster_location
}

# ── Artifact Registry ──

output "artifact_registry_repository" {
  description = "Artifact Registry Docker repository URL"
  value       = module.artifact_registry.repository_url
}

# ── IAM ──

output "gitops_service_account" {
  description = "GitOps controller service account email"
  value       = module.iam.gitops_sa_email
}

output "external_secrets_service_account" {
  description = "External Secrets service account email"
  value       = module.iam.external_secrets_sa_email
}

# ── Secret Manager ──

output "secret_manager_project" {
  description = "Project containing Secret Manager secrets"
  value       = module.secret_manager.project_id
}

output "secret_names" {
  description = "Names of the provisioned Secret Manager secrets"
  value       = [for s in google_secret_manager_secret.secrets : s.name]
}

output "project_id" {
  description = "Project ID where secrets are stored"
  value       = var.project_id
}

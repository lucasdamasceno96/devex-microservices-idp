output "gitops_sa_email" {
  description = "Email of the GitOps controller service account"
  value       = google_service_account.gitops_sa.email
}

output "external_secrets_sa_email" {
  description = "Email of the External Secrets service account"
  value       = google_service_account.external_secrets_sa.email
}

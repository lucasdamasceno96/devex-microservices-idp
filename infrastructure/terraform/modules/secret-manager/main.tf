# Secret Manager Module
# Provisions secrets for shared platform configuration.
# Secret values are managed outside Terraform (via console or gcloud).

resource "google_secret_manager_secret" "secrets" {
  for_each = var.secret_ids

  secret_id = each.key
  project   = var.project_id
  replication {
    auto {}
  }
}

# Secret values are managed outside Terraform (via console or gcloud).

# IAM Module
# Creates platform service accounts and grants Workload Identity bindings
# so GKE workloads can assume GCP IAM roles without static keys.

# Platform service account - used by the GitOps controller (future: Flux/Argo CD)
resource "google_service_account" "gitops_sa" {
  account_id   = var.gitops_sa_id
  display_name = "GitOps Controller Service Account"
  description  = "Used by the GitOps controller running in GKE"
}

# Grant Artifact Registry Reader to the GitOps SA so it can pull images
resource "google_project_iam_member" "gitops_ar_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gitops_sa.email}"
}

# Workload Identity binding: maps the GKE KSA to the GCP SA
resource "google_service_account_iam_member" "gitops_workload_identity" {
  service_account_id = google_service_account.gitops_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.gitops_namespace}/${var.gitops_ksa_name}]"
}

resource "google_service_account" "external_secrets_sa" {
  account_id   = var.external_secrets_sa_id
  display_name = "External Secrets Service Account"
  description  = "Used by External Secrets Operator to access Secret Manager"
}

# Grant Secret Manager access to the External Secrets SA
resource "google_project_iam_member" "external_secrets_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.external_secrets_sa.email}"
}

# Workload Identity binding for External Secrets
resource "google_service_account_iam_member" "external_secrets_workload_identity" {
  service_account_id = google_service_account.external_secrets_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.external_secrets_namespace}/${var.external_secrets_ksa_name}]"
}

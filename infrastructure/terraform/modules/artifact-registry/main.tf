# Artifact Registry Module
# Provisions a Docker repository for storing container images built by CI.

resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = var.repository_id
  format        = "DOCKER"
  description   = "Container image repository for platform workloads"
}

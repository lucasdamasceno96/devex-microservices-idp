output "repository_name" {
  description = "Full name of the Artifact Registry repository"
  value       = google_artifact_registry_repository.repo.name
}

output "repository_url" {
  description = "Docker registry URL"
  value       = "${var.region}-docker.pkg.dev/${google_artifact_registry_repository.repo.project}/${var.repository_id}"
}

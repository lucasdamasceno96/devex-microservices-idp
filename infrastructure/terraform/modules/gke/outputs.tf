output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.gke.name
}

output "cluster_location" {
  description = "Location of the GKE cluster (region)"
  value       = google_container_cluster.gke.location
}

output "cluster_endpoint" {
  description = "Endpoint of the GKE cluster control plane"
  value       = google_container_cluster.gke.endpoint
  sensitive   = true
}

output "workload_identity_pool" {
  description = "Workload Identity pool for the project (used for IAM bindings)"
  value       = "${google_container_cluster.gke.project}.svc.id.goog"
}

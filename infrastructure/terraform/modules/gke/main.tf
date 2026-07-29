# GKE Module
# Provisions a private GKE Autopilot cluster. No node pool management needed.

resource "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.region

  enable_autopilot = true

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr
  }

  network    = var.network_id
  subnetwork = var.subnet_id

  ip_allocation_policy {}

  release_channel {
    channel = var.release_channel
  }

  deletion_protection = false
}

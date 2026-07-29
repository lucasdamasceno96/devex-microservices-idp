# Lab Environment - Root Module
# Wires together all platform modules to provision the shared cloud foundation.

# Enable required GCP APIs before provisioning resources
resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
  ])

  project = var.project_id
  service = each.key

  disable_on_destroy = false
}

# Network fabric: VPC, subnet, Cloud NAT
module "network" {
  source = "../../modules/network"

  network_name = var.network_name
  subnet_name  = var.subnet_name
  subnet_cidr  = var.subnet_cidr
  region       = var.region
  router_name  = var.router_name
  nat_name     = var.nat_name

  depends_on = [google_project_service.services]
}

# GKE Autopilot cluster
module "gke" {
  source = "../../modules/gke"

  cluster_name = var.cluster_name
  region       = var.region
  network_id   = module.network.network_id
  subnet_id    = module.network.subnet_id

  depends_on = [google_project_service.services]
}

# Artifact Registry for container images
module "artifact_registry" {
  source = "../../modules/artifact-registry"

  region        = var.region
  repository_id = var.artifact_registry_repo

  depends_on = [google_project_service.services]
}

# IAM: platform service accounts and Workload Identity bindings
module "iam" {
  source = "../../modules/iam"

  gitops_sa_id                = var.gitops_sa_id
  gitops_namespace            = var.gitops_namespace
  gitops_ksa_name             = var.gitops_ksa_name
  external_secrets_sa_id      = var.external_secrets_sa_id
  external_secrets_namespace  = var.external_secrets_namespace
  external_secrets_ksa_name   = var.external_secrets_ksa_name

  depends_on = [google_project_service.services]
}

# Secret Manager for shared platform secrets
module "secret_manager" {
  source = "../../modules/secret-manager"

  secret_ids = var.secret_ids

  depends_on = [google_project_service.services]
}

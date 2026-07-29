# ── Project ──

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for all resources"
  type        = string
}

# ── Network ──

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
}

variable "router_name" {
  description = "Name of the Cloud Router"
  type        = string
}

variable "nat_name" {
  description = "Name of the Cloud NAT gateway"
  type        = string
}

# ── GKE ──

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

# ── Artifact Registry ──

variable "artifact_registry_repo" {
  description = "ID of the Artifact Registry repository"
  type        = string
}

# ── IAM ──

variable "gitops_sa_id" {
  description = "ID for the GitOps controller service account"
  type        = string
}

variable "gitops_namespace" {
  description = "Kubernetes namespace where the GitOps controller will run"
  type        = string
}

variable "gitops_ksa_name" {
  description = "Kubernetes service account name for the GitOps controller"
  type        = string
}

variable "external_secrets_sa_id" {
  description = "ID for the External Secrets service account"
  type        = string
}

variable "external_secrets_namespace" {
  description = "Kubernetes namespace where External Secrets will run"
  type        = string
}

variable "external_secrets_ksa_name" {
  description = "Kubernetes service account name for External Secrets"
  type        = string
}

# ── Secret Manager ──

variable "secret_ids" {
  description = "Set of Secret Manager secret IDs to provision"
  type        = set(string)
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

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

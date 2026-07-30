variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "secret_ids" {
  description = "Set of Secret Manager secret IDs to provision"
  type        = set(string)
}

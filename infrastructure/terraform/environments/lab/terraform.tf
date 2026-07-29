# Backend and provider configuration for the lab environment.
# State is stored remotely in GCS for team access and locking.

terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "ldp21k-labs-tfstate"
    prefix = "all"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

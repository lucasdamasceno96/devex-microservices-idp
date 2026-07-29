#!/usr/bin/env bash
set -euo pipefail

# bootstrap.sh - One-time setup script for GCP project bootstrap
# Run this once per GCP project before deploying the platform.

echo "=== Bootstrapping GCP project ==="

PROJECT_ID="${GCP_PROJECT_ID:-ldp21k-labs}"
REGION="${GCP_REGION:-us-central1}"
STATE_BUCKET="${TF_STATE_BUCKET:-ldp21k-labs-tfstate}"

# Enable required APIs
echo "Enabling GCP APIs..."
gcloud services enable \
  compute.googleapis.com \
  container.googleapis.com \
  artifactregistry.googleapis.com \
  secretmanager.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  cloudresourcemanager.googleapis.com \
  --project="${PROJECT_ID}"

# Create Terraform state bucket if it doesn't exist
if ! gsutil ls "gs://${STATE_BUCKET}" &>/dev/null; then
  echo "Creating Terraform state bucket: gs://${STATE_BUCKET}"
  gsutil mb -p "${PROJECT_ID}" -l "${REGION}" "gs://${STATE_BUCKET}"
  gsutil versioning set on "gs://${STATE_BUCKET}"
fi

echo "Bootstrap complete."
echo "Next: run ./deploy.sh"

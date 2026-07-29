#!/usr/bin/env bash
set -euo pipefail

# deploy.sh - Full platform deployment
# Provisions infrastructure, configures kubectl, installs platform components.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Deploying devex-microservices-idp ==="

# Step 1: Infrastructure via Terraform
echo ""
echo "[1/4] Provisioning GCP infrastructure with Terraform..."
cd "${ROOT_DIR}/infrastructure/terraform/environments/lab"
terraform init
terraform apply -auto-approve

# Step 2: Connect kubectl
echo ""
echo "[2/4] Configuring kubectl..."
CLUSTER_NAME="devex-idp-autopilot"
CLUSTER_REGION="us-central1"
gcloud container clusters get-credentials "${CLUSTER_NAME}" \
  --region="${CLUSTER_REGION}" \
  --project="${GCP_PROJECT_ID:-ldp21k-labs}"

# Step 3: Install ArgoCD
echo ""
echo "[3/4] Installing ArgoCD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Step 4: Install External Secrets Operator
echo ""
echo "[4/4] Installing External Secrets Operator..."
kubectl create namespace external-secrets --dry-run=client -o yaml | kubectl apply -f -
helm repo add external-secrets https://charts.external-secrets.io --force-update
helm upgrade --install external-secrets external-secrets/external-secrets \
  -n external-secrets \
  --set serviceAccount.annotations."iam\.gke\.io/gcp-service-account"="${GCP_PROJECT_ID:-ldp21k-labs}"

# Done
echo ""
echo "=== Deployment complete ==="
echo ""
echo "Next steps:"
echo "  1. Access ArgoCD UI:"
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 2>/dev/null || echo "<retrieve manually>")
echo "     kubectl port-forward -n argocd svc/argocd-server 8080:443"
echo "     URL: https://localhost:8080"
echo "     User: admin"
echo "     Password: ${ARGOCD_PASSWORD}"
echo ""
echo "  2. Apply the root app:"
echo "     kubectl apply -f gitops/dev/root-app.yaml"
echo ""
echo "  3. Check sync status in ArgoCD UI"

#!/usr/bin/env bash
set -euo pipefail

# validate.sh - Platform health check
# Verifies infrastructure, cluster access, and platform component status.

echo "=== Platform Validation ==="
FAILURES=0

check() {
  local desc="$1"
  shift
  if "$@" &>/dev/null; then
    echo "  [OK]   ${desc}"
  else
    echo "  [FAIL] ${desc}"
    FAILURES=$((FAILURES + 1))
  fi
}

echo ""
echo "--- Terraform ---"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

check "Terraform is installed" terraform version

echo ""
echo "--- GCP ---"
check "gcloud is installed" gcloud version
check "GCP authentication active" gcloud auth print-access-token

echo ""
echo "--- GKE ---"
check "kubectl cluster access" kubectl cluster-info
check "Namespaces exist (dev/staging/production)" \
  bash -c "kubectl get ns dev staging production"

echo ""
echo "--- ArgoCD ---"
check "ArgoCD server is running" \
  bash -c "kubectl get deployment argocd-server -n argocd"
check "ArgoCD Applications synced" \
  bash -c "kubectl get applications -n argocd"

echo ""
echo "--- External Secrets ---"
check "External Secrets operator running" \
  bash -c "kubectl get deployment -n external-secrets"

echo ""
echo "--- Artifact Registry ---"
check "Artifact Registry repository exists" \
  bash -c "gcloud artifacts repositories describe devex-idp --location=us-central1"

echo ""
echo "--- Summary ---"
if [ "${FAILURES}" -eq 0 ]; then
  echo "All checks passed."
else
  echo "${FAILURES} check(s) failed."
  exit 1
fi

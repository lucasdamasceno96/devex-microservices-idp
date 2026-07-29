#!/usr/bin/env bash
set -euo pipefail

# destroy.sh - Tears down the complete platform infrastructure
# Warning: This destroys all GCP resources provisioned by Terraform.

echo "=== WARNING: This will destroy the entire platform ==="
echo "This action is irreversible."
read -rp "Type 'DESTROY' to confirm: " confirmation

if [ "${confirmation}" != "DESTROY" ]; then
  echo "Aborted."
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo ""
echo "[1/2] Destroying Terraform infrastructure..."
cd "${ROOT_DIR}/infrastructure/terraform/environments/lab"
terraform destroy -auto-approve

echo ""
echo "[2/2] Cleaning up local files..."
rm -rf "${ROOT_DIR}/infrastructure/terraform/environments/lab/.terraform"

echo ""
echo "=== Platform destroyed ==="

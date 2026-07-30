project_id = "ldp21k-labs"
region     = "us-central1"

network_name = "devex-idp-vpc"
subnet_name  = "devex-idp-subnet"
subnet_cidr  = "10.0.0.0/20"
router_name  = "devex-idp-router"
nat_name     = "devex-idp-nat"

cluster_name = "devex-idp-autopilot"

artifact_registry_repo = "devex-idp"

gitops_sa_id     = "devex-idp-gitops"
gitops_namespace = "argocd"
gitops_ksa_name  = "argocd-application-controller"

external_secrets_sa_id     = "devex-idp-ext-secrets"
external_secrets_namespace = "external-secrets"
external_secrets_ksa_name  = "external-secrets"

secret_ids = [
  "devex-idp-db-password",
  "devex-idp-api-key",
]

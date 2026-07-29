# Troubleshooting Guide

## Common Issues

### Terraform: "Error accessing state"

**Symptom**: `terraform init` fails with "Failed to get existing workspaces"

**Cause**: Incorrect GCP credentials or missing GCS bucket.

**Fix**:
```bash
gcloud auth application-default login
gsutil ls gs://ldp21k-labs-tfstate  # Verify bucket exists
```

---

### GKE: "Cluster not found"

**Symptom**: `kubectl` commands fail with "cluster not found"

**Fix**:
```bash
gcloud container clusters get-credentials devex-idp-autopilot \
  --region=us-central1 \
  --project=ldp21k-labs
```

---

### ArgoCD: Applications stuck in "Unknown" or "Progressing"

**Symptom**: ArgoCD UI shows application health as Unknown or indefinitely Progressing.

**Common causes**:

1. **Image pull error** — Check the pod events:
   ```bash
   kubectl describe pod -n dev -l app=service-generator
   ```
   If "ErrImagePull", verify the image exists in Artifact Registry and the tag is correct.

2. **Helm chart path wrong** — Verify the `path` in the ArgoCD Application matches the chart location:
   ```yaml
   source:
     path: platform/helm-chart  # Must be correct relative path in repo
   ```

3. **Sync not triggered** — Force a sync from ArgoCD UI or CLI:
   ```bash
   argocd app sync service-generator
   ```

---

### External Secrets: Secrets not syncing

**Symptom**: `ExternalSecret` resource shows "SecretSyncedError"

**Fix**:

1. Verify Workload Identity binding:
   ```bash
   gcloud iam service-accounts get-iam-policy \
     devex-idp-ext-secrets@ldp21k-labs.iam.gserviceaccount.com
   ```

2. Check ESO logs:
   ```bash
   kubectl logs -n external-secrets deployment/external-secrets
   ```

3. Verify Secret Manager secret exists:
   ```bash
   gcloud secrets list --project=ldp21k-labs
   ```

---

### CI: "Permission denied" when pushing to GitOps repo

**Symptom**: GitHub Actions fails at the "Update GitOps" step.

**Fix**: Ensure `GITOPS_TOKEN` secret is set in the repository Settings → Secrets → Actions with a PAT that has write access to the repo.

---

### Probes failing: "connection refused"

**Symptom**: Pods restarting with "Liveness probe failed"

**Fix**:

1. Check the port — the Helm chart defaults to 3000:
   ```yaml
   livenessProbe:
     httpGet:
       path: /health
       port: http  # Maps to containerPort 3000
   ```

2. Check if the app is actually listening:
   ```bash
   kubectl exec -n dev deployment/service-generator -- wget -qO- http://localhost:3000/health
   ```

---

### Docker: Trivy scan finding vulnerabilities

**Symptom**: CI pipeline fails with HIGH/CRITICAL vulnerabilities.

**Fix**:
- Update base image: `FROM node:20-alpine` → newer version
- Run `npm audit fix` in the app
- If false positive or accepted risk, adjust Trivy severity threshold in workflow

---

## Diagnostic Commands

```bash
# Check all ArgoCD applications
kubectl get applications -n argocd

# Check pod status in all namespaces
kubectl get pods -A | grep -v Running

# Check ArgoCD server logs
kubectl logs -n argocd deployment/argocd-server

# Check Terraform state
terraform state list -state=infrastructure/terraform/environments/lab/terraform.tfstate

# List GCP resources
gcloud compute networks list
gcloud container clusters list
gcloud artifacts repositories list
gcloud secrets list
```

## Getting Help

1. Check ArgoCD UI first — it shows sync errors with detailed messages
2. Check pod events: `kubectl describe pod -n <namespace> <pod-name>`
3. Check platform component logs: `kubectl logs -n <namespace> deployment/<name>`
4. Review Terraform state: `terraform state list`

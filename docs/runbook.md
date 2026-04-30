# TaskApp Operational Runbook

## Prerequisites
```bash
export KOPS_STATE_STORE=s3://taskapp-kops-state-amara
export CLUSTER_NAME=k8s.taskbymara.online
export AWS_REGION=us-east-1
```

---

## 1. Deploy From Scratch

```bash
bash scripts/create.sh
```

This will:
1. Run `terraform apply` to create all AWS resources
2. Create the Kops cluster on private subnets
3. Wait for cluster to be ready
4. Deploy all K8s manifests

**Expected time:** 20-30 minutes

---

## 2. Validate Infrastructure

```bash
bash scripts/validate.sh
```

Or manually:
```bash
# Cluster health
kops validate cluster --name=${CLUSTER_NAME}

# All nodes ready
kubectl get nodes -o wide

# All pods running
kubectl get pods -n taskapp -o wide

# Check ingress
kubectl get ingress -n taskapp

# Check SSL certificate
kubectl get certificate -n taskapp

# Terraform drift check
terraform -chdir=terraform plan
```

---

## 3. Scale Worker Nodes

```bash
# Edit the instance group
kops edit ig nodes-us-east-1a \
  --name=${CLUSTER_NAME} \
  --state=${KOPS_STATE_STORE}

# Change minSize and maxSize, then apply:
kops update cluster ${CLUSTER_NAME} \
  --state=${KOPS_STATE_STORE} --yes

kops rolling-update cluster \
  --name=${CLUSTER_NAME} \
  --state=${KOPS_STATE_STORE} --yes
```

---

## 4. Deploy New Application Version

```bash
# Build new image
docker build -t taskapp-backend:v1.0.X app/backend/
docker tag taskapp-backend:v1.0.X \
  781856668470.dkr.ecr.us-east-1.amazonaws.com/taskapp-backend:v1.0.X
docker push \
  781856668470.dkr.ecr.us-east-1.amazonaws.com/taskapp-backend:v1.0.X

# Update manifest and push to GitHub
# ArgoCD will automatically deploy within 3 minutes
git add k8s/base/backend/deployment.yaml
git commit -m "feat: update backend to v1.0.X"
git push
```

---

## 5. Rotate Database Credentials

```bash
# Update the secret
kubectl edit secret db-credentials -n taskapp

# Restart backend to pick up new credentials
kubectl rollout restart deployment/backend -n taskapp

# Verify
kubectl rollout status deployment/backend -n taskapp
```

---

## 6. Test Database Persistence

```bash
# Delete postgres pod
kubectl delete pod postgres-0 -n taskapp

# Watch it restart
kubectl get pods -n taskapp --watch

# Verify data survived
kubectl exec -n taskapp postgres-0 -- \
  psql -U taskapp -c "SELECT COUNT(*) FROM tasks;"
```

---

## 7. Troubleshoot Common Failures

### Pods not starting
```bash
kubectl describe pod POD_NAME -n taskapp
kubectl logs POD_NAME -n taskapp --tail=50
```

### Backend database connection issues
```bash
kubectl exec -n taskapp \
  $(kubectl get pod -n taskapp -l app=backend \
  -o jsonpath='{.items[0].metadata.name}') \
  -- env | grep DATABASE
```

### SSL certificate not renewing
```bash
kubectl describe certificate taskapp-tls -n taskapp
kubectl logs -n cert-manager -l app=cert-manager --tail=30
```

### Cluster node not ready
```bash
kops validate cluster --name=${CLUSTER_NAME}
kubectl describe node NODE_NAME
```

### ArgoCD out of sync
```bash
kubectl get application -n argocd
# Force sync:
kubectl patch application taskapp -n argocd \
  --type merge -p '{"operation":{"sync":{}}}'
```

---

## 8. Destroy All Infrastructure

```bash
bash scripts/destroy.sh
```

> ⚠️ This permanently deletes the cluster and all AWS resources.
> Ensure data is backed up before running.


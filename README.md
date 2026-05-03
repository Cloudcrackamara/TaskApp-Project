# 🚀 Cloud-Native TaskApp — Production Kubernetes Deployment on AWS

> A full-stack task management application deployed on a self-managed, highly available Kubernetes cluster on AWS — built with zero shortcuts, real infrastructure decisions, and production-grade engineering from the ground up.

**Live Application:** [https://taskapp.taskbymara.online](https://taskapp.taskbymara.online)  
**GitHub Repository:** [https://github.com/Cloudcrackamara/TaskApp-Project](https://github.com/Cloudcrackamara/TaskApp-Project)

---

## 🏷️ Tech Stack

### ☁️ Cloud & Infrastructure
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Amazon EC2](https://img.shields.io/badge/Amazon%20EC2-FF9900?style=for-the-badge&logo=amazonec2&logoColor=white)
![Amazon S3](https://img.shields.io/badge/Amazon%20S3-569A31?style=for-the-badge&logo=amazons3&logoColor=white)
![Amazon ECR](https://img.shields.io/badge/Amazon%20ECR-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Amazon Route53](https://img.shields.io/badge/Route%2053-8C4FFF?style=for-the-badge&logo=amazonaws&logoColor=white)
![Amazon EBS](https://img.shields.io/badge/Amazon%20EBS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)

### ☸️ Kubernetes & Orchestration
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![kOps](https://img.shields.io/badge/kOps-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-0F1689?style=for-the-badge&logo=helm&logoColor=white)
![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)

### 🐳 Containers
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

### 🌐 Networking & Security
![NGINX](https://img.shields.io/badge/NGINX-009639?style=for-the-badge&logo=nginx&logoColor=white)
![Let's Encrypt](https://img.shields.io/badge/Let's%20Encrypt-003A70?style=for-the-badge&logo=letsencrypt&logoColor=white)
![Calico](https://img.shields.io/badge/Calico%20CNI-FB8C00?style=for-the-badge&logo=kubernetes&logoColor=white)

### 💻 Application Stack
![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)
![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)

### 🔧 Developer Tools
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)
![VSCode](https://img.shields.io/badge/VSCode-007ACC?style=for-the-badge&logo=visualstudiocode&logoColor=white)

---

## 📋 Project Overview

### What I Built
A production-grade, cloud-native deployment of **TaskApp** — a Kanban-style team task management platform — on AWS using a self-managed Kubernetes cluster, Terraform infrastructure as code, and GitOps-driven continuous delivery via ArgoCD.

This is not a tutorial project. There is no guided walkthrough where things work on the first attempt. This is a real system designed to survive Availability Zone failures, handle production traffic securely over HTTPS, and deploy automatically on every Git push.

### The Problem It Solves
Most cloud deployments start with the application and treat infrastructure as an afterthought. Then production happens. The architecture cannot survive an AZ failure. Credentials are hardcoded. Infrastructure exists only in someone's memory instead of being defined, reviewed, and version-controlled as code.

This project takes the opposite approach: **infrastructure first, application second.**

### Real-World Relevance
Every decision in this project mirrors what production engineering teams face daily:
- How do you build infrastructure that survives a data center failure?
- How do you manage secrets without putting them in Git?
- How do you deploy new versions without downtime?
- How do you automate everything so human error is removed from the deployment process?

---

## 🏗️ Architecture Overview

### Full System Design

```
┌─────────────────────────────────────────────────────────────────┐
│                        INTERNET                                  │
└─────────────────────┬───────────────────────────────────────────┘
                       │
              ┌────────▼────────┐
              │   Route53 DNS   │
              │ taskbymara.online│
              └────────┬────────┘
                       │
              ┌────────▼────────┐
              │  AWS ELB (ALB)  │
              │  Created by     │
              │  NGINX Ingress  │
              └────────┬────────┘
                       │
    ┌──────────────────┼──────────────────┐
    │                  │                  │
┌───▼────┐      ┌──────▼──────┐    ┌──────▼──────┐
│Public  │      │   Public    │    │   Public    │
│Subnet  │      │   Subnet    │    │   Subnet    │
│1a      │      │   1b        │    │   1c        │
│NAT GW  │      │   NAT GW    │    │   NAT GW    │
└───┬────┘      └──────┬──────┘    └──────┬──────┘
    │                  │                  │
┌───▼────┐      ┌──────▼──────┐    ┌──────▼──────┐
│Private │      │   Private   │    │   Private   │
│Subnet  │      │   Subnet    │    │   Subnet    │
│1a      │      │   1b        │    │   1c        │
│Master  │      │   Master    │    │   Master    │
│Worker  │      │   Worker    │    │   Worker    │
└────────┘      └─────────────┘    └─────────────┘
                  VPC: 10.0.0.0/16
```

### Request Flow
```
User Browser
  → HTTPS request to taskapp.taskbymara.online
  → Route53 resolves to AWS ELB hostname (CNAME)
  → ELB routes to NGINX Ingress Controller
  → NGINX checks path:
      /api/* → Backend Service (Flask, port 5000)
      /      → Frontend Service (nginx, port 80)
  → Service routes to healthy pod replica
  → Backend queries PostgreSQL via Kubernetes service DNS
  → Response returned to user
```

### High Availability Design
- **3 Control Plane nodes** across 3 AZs — if one AZ fails, the remaining two maintain etcd quorum (2/3 majority). The cluster keeps running.
- **3 Worker nodes** across 3 AZs — pods are rescheduled automatically if a node goes down.
- **3 NAT Gateways** — one per AZ. If us-east-1a fails, us-east-1b and us-east-1c continue routing outbound traffic independently.
- **2 replicas per application** — frontend and backend each run 2 pods across different nodes.

### Security Architecture
- Zero public IPs on any cluster node — private subnet topology throughout
- All external access through NGINX Ingress (ports 80/443 only)
- SSH access only through a Bastion host
- IAM least-privilege: dedicated `taskapp-kops-admins` group with scoped policies
- Secrets stored in Kubernetes Secrets — never committed to Git
- ECR repositories private with IMMUTABLE image tags

---

## 🔧 Tech Stack Breakdown

### Cloud Services (AWS)
| Service | Purpose |
|---------|---------|
| EC2 (t3.medium) | Kubernetes control plane and worker nodes |
| EBS (gp2, 10Gi) | Persistent storage for PostgreSQL StatefulSet |
| S3 | Terraform remote state + kOps cluster state |
| ECR | Private Docker image registry (frontend + backend) |
| ELB | Load balancer created automatically by NGINX Ingress |
| Route53 | DNS hosted zone for taskbymara.online |
| DynamoDB | Terraform state locking (prevents concurrent apply conflicts) |
| IAM | Least-privilege access for kOps cluster operations |

### Infrastructure as Code
- **Terraform** with modular structure (`vpc`, `iam`, `ecr`, `dns` modules)
- Remote state stored in S3 with DynamoDB locking
- All 48 AWS resources created from a single `terraform apply` — zero manual console clicks

### Containerization
- **Docker** for building and packaging the React frontend and Flask backend
- Multi-stage Dockerfile for the frontend (Node build stage → nginx serve stage)
- Images tagged with immutable semantic versions (never `latest`)
- Private ECR repositories with lifecycle policies to auto-delete untagged images

### Kubernetes
- **kOps** for self-managed cluster (not EKS — intentional choice for operational depth)
- **Calico CNI** for pod networking with NetworkPolicy support
- **NGINX Ingress Controller** via Helm for traffic routing
- **cert-manager** via Helm for automated SSL certificate management
- **ArgoCD** for GitOps continuous delivery

### GitOps (ArgoCD)
- ArgoCD monitors `k8s/base/` in the GitHub repository
- Any merged commit automatically syncs to the cluster
- Self-heal enabled — manual cluster changes are automatically reverted
- Eliminates the need for manual `kubectl apply` in any deployment

---

## 📦 Implementation

### Phase 1: Infrastructure Foundation (Terraform)

**What I did:**
Set up the complete AWS network architecture and supporting services using Terraform before a single line of application code touched AWS.

**Why:**
Infrastructure built after the application is infrastructure built to fit the application's current shape. That means it breaks when the application grows. Starting with infrastructure means every future decision has a solid, well-designed foundation.

**Key decisions:**

```hcl
# VPC CIDR: 10.0.0.0/16
# Why: 65,536 IPs — enough for autoscaling, staging environments,
# and future services without needing to resize the VPC later.

# 6 subnets across 3 AZs
private_subnets = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
public_subnets  = ["10.0.1.0/24",  "10.0.2.0/24",  "10.0.3.0/24"]

# One NAT Gateway per AZ
one_nat_gateway_per_az = true
# Why: A single shared NAT Gateway is a hidden single point of failure.
# If that AZ goes down, ALL private subnet nodes lose internet access.
```

**Terraform remote backend:**
```hcl
backend "s3" {
  bucket         = "taskapp-tfstate-amara"
  key            = "production/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "taskapp-tf-lock"
  encrypt        = true
}
```
DynamoDB locking prevents two engineers (or two CI pipelines) from running `terraform apply` simultaneously and corrupting state.

---

### Phase 2: Kubernetes Cluster (kOps)

**What I did:**
Provisioned a self-managed, multi-master Kubernetes cluster on the private subnets created in Phase 1.

**Why kOps over EKS:**
EKS hides the control plane entirely. With kOps, every decision is explicit: master sizing, etcd configuration, CNI selection, network topology. Understanding what a cloud provider abstracts away is what separates someone who uses Kubernetes from someone who can operate it.

**Cluster specification:**
```bash
kops create cluster \
  --name=k8s.taskbymara.online \
  --cloud=aws \
  --control-plane-count=3 \
  --control-plane-size=t3.medium \
  --node-count=3 \
  --node-size=t3.medium \
  --networking=calico \
  --topology=private \
  --bastion \
  --dns-zone=taskbymara.online \
  --kubernetes-version=1.28.5
```

**Why Calico CNI:**
Calico supports `NetworkPolicy` objects — allowing granular control over which pods can communicate with each other. Flannel does not support NetworkPolicy. In a production environment where you do not want your frontend pods to directly query the database, this matters.

**Spot instance configuration:**
```yaml
mixedInstancesPolicy:
  instances:
  - t3a.medium
  - t3.medium
  onDemandBase: 0
  onDemandAboveBase: 0
  spotAllocationStrategy: capacity-optimized
```
Worker nodes run on spot with fallback types. Masters remain on-demand — you do not gamble with your control plane.

---

### Phase 3: DNS, Ingress & SSL

**What I did:**
Configured Route53 DNS, installed NGINX Ingress Controller, and set up automated SSL certificate management via cert-manager and Let's Encrypt.

**DNS delegation:**
Namecheap was configured with Route53 nameservers. All DNS management moved to AWS, enabling native integration with cert-manager for automatic domain validation.

**Why NGINX Ingress:**
A single ingress controller as the only entry point for cluster traffic. Path-based routing means `/api` goes to Flask, `/` goes to React — without needing separate load balancers per service.

**SSL automation:**
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    solvers:
    - http01:
        ingress:
          class: nginx
```
cert-manager handles the ACME HTTP-01 challenge, certificate issuance, storage as a Kubernetes Secret, and renewal before expiry. Zero manual certificate management.

---

### Phase 4: Application Containerization

**What I did:**
Built Docker images for the React frontend and Flask backend, pushed to private ECR repositories, and deployed to Kubernetes.

**Frontend multi-stage build:**
```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
ARG VITE_API_URL=https://taskapp.taskbymara.online/api
ENV VITE_API_URL=$VITE_API_URL
RUN npm run build

FROM nginx:1.25-alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx-production.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```

**Critical decision — build args for environment variables:**
Vite bakes environment variables into the JavaScript bundle at build time. Setting `VITE_API_URL` in `.env.production` is not enough if the variable is not passed during the Docker build. It must be an explicit `--build-arg`. This was a non-obvious issue that took significant debugging to trace.

**Image tagging policy:**
ECR repositories configured with `IMMUTABLE` tag mutability. Once `v1.0.0` is pushed, it cannot be overwritten. Every deployment is a permanent, auditable artifact.

---

### Phase 5: Kubernetes Application Deployment

**What I did:**
Wrote all Kubernetes manifests for the three-tier application and applied them to the cluster.

**PostgreSQL StatefulSet with persistent storage:**
```yaml
volumeClaimTemplates:
- metadata:
    name: postgres-data
  spec:
    accessModes: ["ReadWriteOnce"]
    storageClassName: "gp2"
    resources:
      requests:
        storage: 10Gi
```
With `Retain` policy — deleting the pod does not delete the data. Tested by deleting `postgres-0` mid-session and verifying data survived the pod recreation.

**Zero-downtime rolling updates:**
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 0
    maxSurge: 1
```
`maxUnavailable: 0` guarantees at least one replica is always serving traffic during deployments. The new pod starts before the old one stops.

**Resource limits (as specified):**
```yaml
resources:
  requests:
    memory: "526Mi"
    cpu: "250m"
  limits:
    memory: "526Mi"
    cpu: "500m"
```

---

### Phase 6: GitOps with ArgoCD

**What I did:**
Installed ArgoCD and configured it to watch the GitHub repository for changes to `k8s/base/`.

**Why GitOps:**
Manual deployments introduce human error. GitOps means the cluster's desired state is always defined in Git. Any deviation — whether from a manual kubectl command or a failed deployment — is automatically detected and corrected.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: taskapp
  namespace: argocd
spec:
  source:
    repoURL: https://github.com/Cloudcrackamara/TaskApp-Project.git
    path: k8s/base
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

With `selfHeal: true`, if someone runs `kubectl delete deployment frontend` directly, ArgoCD will recreate it within minutes. The Git repository is the source of truth — not the cluster's current state.

---

### Phase 7: Security Implementation

**What I did:**
Applied security controls across every layer of the stack.

**IAM least privilege:**
Created a dedicated `taskapp-kops-admins` IAM group with only the permissions kOps requires. No root account usage. No hardcoded AWS credentials in any file.

**Secret management:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
  namespace: taskapp
type: Opaque
stringData:
  DATABASE_URL: postgresql://taskapp:***@postgres:5432/taskapp
  DATABASE_USER: taskapp
  DATABASE_PASSWORD: ***
```
Credentials stored in Kubernetes Secrets. Never committed to Git. The secret file in the repository is a template — actual values populated at deployment time.

**Network segmentation:**
- Private subnet topology (all nodes)
- Security groups restrict inter-node traffic to required ports only
- NGINX Ingress is the only publicly accessible endpoint
- Bastion host as the sole SSH entry point

---

## 🔄 CI/CD Workflow

```
Developer pushes code
       ↓
GitHub repository updated
       ↓
ArgoCD detects change in k8s/base/ (polling every 3 minutes)
       ↓
ArgoCD compares desired state (Git) vs actual state (cluster)
       ↓
If diff detected → ArgoCD applies the change
       ↓
New pods created with rolling update (maxUnavailable: 0)
       ↓
Old pods terminated after new pods pass health checks
       ↓
Zero-downtime deployment complete
       ↓
ArgoCD reports Synced + Healthy
```

For application image updates:
```bash
# Build and push new image
docker build --build-arg VITE_API_URL=https://taskapp.taskbymara.online/api \
  -t taskapp-frontend:v1.0.X app/frontend/
docker push 781856668470.dkr.ecr.us-east-1.amazonaws.com/taskapp-frontend:v1.0.X

# Update manifest and push — ArgoCD handles the rest
git add k8s/base/frontend/deployment.yaml
git commit -m "feat: update frontend to v1.0.X"
git push
```

---

## 🔥 Challenges & Solutions

### Challenge 1: Silent EC2 Launch Failures
**Symptom:** `kops validate cluster` returned no errors but only the bastion host was running. No masters. No workers.

**Root cause:** AWS free tier silently rejected every `t3a.medium` instance launch. The error was buried in Autoscaling Group activity logs — not surfaced in kOps output.

**How I found it:**
```bash
aws autoscaling describe-scaling-activities \
  --query 'Activities[*].{Status:StatusCode,Description:Description}' \
  --output table
```
The activity log showed: *"The specified instance type is not eligible for Free Tier."*

**Fix:** Upgraded AWS account to paid tier. Lesson: silent failures require bottom-up debugging — you cannot wait for an error message that is never coming.

---

### Challenge 2: One-Letter Domain Typo
**Symptom:** kOps could not find the DNS zone. Everything failed with a cryptic zone lookup error.

**Root cause:** Terraform variable was set to `taskbyamara.online` instead of `taskbymara.online`. Route53 created the hosted zone for the wrong domain. Namecheap was updated with nameservers for a domain that did not exist.

**Fix:** Corrected the variable, ran `terraform apply` to recreate the hosted zone with the correct name, obtained new nameservers, updated Namecheap, waited for propagation.

**Lesson:** Always verify DNS with `nslookup -type=NS yourdomain.com 8.8.8.8` before proceeding.

---

### Challenge 3: Six Pods, Six Different CrashLoopBackOff Causes
**Symptom:** Every application pod crashed on first deployment.

| Pod | Root Cause | Fix |
|-----|-----------|-----|
| PostgreSQL | EBS mount directory not empty (lost+found) | Added `subPath: pgdata` to volume mount |
| Backend | Health probe checking `/health` (endpoint did not exist) | Switched to TCP socket probe |
| Frontend | nginx config loading SSL certs for a different domain | Replaced config with simple HTTP server (SSL terminates at ingress) |
| Frontend | `VITE_API_URL` not baked into build | Passed as Docker `--build-arg` explicitly |
| Backend | Ingress routing `/api` to frontend service | Fixed path order in ingress rules (`/api` before `/`) |
| Backend | Secret variable names mismatched app expectations | Added `DATABASE_USER`/`DATABASE_PASSWORD` to Secret |

**Lesson:** CrashLoopBackOff is a symptom, not a cause. Each pod requires individual log analysis.

---

## 💡 Key Learnings

**1. Infrastructure design is a forcing function.**
The decisions made in the VPC — CIDR sizing, subnet layout, NAT Gateway count — constrain every future architectural decision. Getting these wrong early is expensive to fix later.

**2. Silent failures are the hardest to debug.**
In distributed systems, things often fail without announcing themselves. The skill is knowing where to look and what questions to ask when there is no error message.

**3. Kubernetes environment variables require build-time injection for compiled frontends.**
`VITE_API_URL` in `.env.production` is meaningless if the Docker build does not receive it as a build argument. This is a common production gotcha that tutorials rarely cover.

**4. SSL termination belongs at the ingress layer in Kubernetes.**
Containers should serve plain HTTP. The ingress controller handles TLS. Putting SSL configuration inside the container nginx config causes crashes because the certificates don't exist inside the container.

**5. GitOps removes the human from the deployment loop.**
The most dangerous part of any deployment is the human executing it under pressure. ArgoCD eliminates that variable.

---

## 🚀 Future Improvements

- **Horizontal Pod Autoscaler (HPA)** — automatically scale backend replicas based on CPU/memory under load
- **AWS RDS** — replace containerized PostgreSQL with managed RDS for automated backups, Multi-AZ failover, and read replicas
- **External Secrets Operator** — move secrets from Kubernetes Secrets to AWS Secrets Manager for centralised secret rotation
- **tfsec + tflint** — add infrastructure security scanning and linting to a CI pipeline for every Terraform change
- **Prometheus + Grafana** — cluster and application metrics with dashboards and alerting
- **Cluster Autoscaler** — automatically add/remove worker nodes based on pending pod demand

---

## 📸 Screenshots

### Live Application
![TaskApp Dashboard](docs/evidence/dashboard-screenshot.png)

### Cluster Validation
```
NAME                                    STATUS   ROLES           AGE   VERSION
i-02e77f7619907e93e                     Ready    node            19h   v1.28.5
i-0306d694f6964442a4                    Ready    control-plane   19h   v1.28.5
i-03cae674223d2a111                     Ready    node            19h   v1.28.5
i-0846ecd0f4295c4d2                     Ready    node            19h   v1.28.5
i-0da2ce8941ad6f6db                     Ready    control-plane   19h   v1.28.5
i-0eafc41d1052fa587                     Ready    control-plane   19h   v1.28.5
```

### ArgoCD GitOps Dashboard
![ArgoCD Synced](docs/evidence/argocd-synced.png)

### All Pods Running
```
NAME                                    READY   STATUS    RESTARTS   AGE
backend-64b68ccb78-d48zb                1/1     Running   0          2h
backend-64b68ccb78-tdxl2               1/1     Running   0          2h
frontend-67778bfb6b-4sk5t              1/1     Running   0          2h
frontend-67778bfb6b-9rrkv              1/1     Running   0          2h
postgres-0                             1/1     Running   0          2h
```

---

## 📁 Repository Structure

```
TaskApp-Project/
├── terraform/                    # All AWS infrastructure as code
│   ├── backend/                  # S3 + DynamoDB remote state
│   └── modules/
│       ├── vpc/                  # VPC, subnets, NAT Gateways
│       ├── iam/                  # IAM groups, policies, kOps S3 bucket
│       ├── ecr/                  # Container registries
│       └── dns/                  # Route53 hosted zone
│
├── kops/                         # Kubernetes cluster configuration
│   ├── cluster.yaml              # Cluster specification
│   └── instancegroups.yaml       # Node groups with spot instance config
│
├── k8s/                          # Kubernetes application manifests
│   └── base/
│       ├── namespace.yaml
│       ├── postgres/             # StatefulSet + PVC + Secret
│       ├── backend/              # Deployment + Service + ConfigMap
│       ├── frontend/             # Deployment + Service
│       └── ingress/              # NGINX Ingress + ClusterIssuer
│
├── argocd/                       # GitOps configuration
│   └── application.yaml
│
├── scripts/                      # Automation scripts
│   ├── create.sh                 # Full infrastructure creation
│   ├── validate.sh               # Health check all components
│   └── destroy.sh                # Safe teardown with confirmation
│
├── app/                          # Application source code
│   ├── frontend/                 # React + Vite + nginx
│   └── backend/                  # Flask + SQLAlchemy + PostgreSQL
│
└── docs/
    ├── architecture.md           # System design and decisions
    ├── runbook.md                # Operational procedures
    ├── cost-analysis.md          # Monthly cost breakdown
    └── evidence/                 # Validation screenshots and logs
```

---

## ⚡ Quick Start

### Prerequisites
- AWS CLI configured with appropriate IAM permissions
- Terraform >= 1.5.0
- kOps >= 1.28
- kubectl
- Helm >= 3.0
- Docker

### Deploy Everything
```bash
# Clone the repository
git clone https://github.com/Cloudcrackamara/TaskApp-Project.git
cd TaskApp-Project

# Deploy infrastructure and cluster
bash scripts/create.sh

# Validate everything is healthy
bash scripts/validate.sh
```

### Validate the Cluster
```bash
export KOPS_STATE_STORE=s3://taskapp-kops-state-amara
export CLUSTER_NAME=k8s.taskbymara.online

kops validate cluster --name=${CLUSTER_NAME}
kubectl get nodes -o wide
kubectl get pods -n taskapp
```

### Destroy All Infrastructure
```bash
# Requires typing 'destroy' to confirm — not accidental
bash scripts/destroy.sh
```

---

## 💰 Cost Analysis

| Resource | Count | Monthly Cost |
|----------|-------|--------------|
| EC2 t3.medium (control plane) | 3 | ~$90 |
| EC2 t3.medium (workers, spot) | 3 | ~$36 |
| NAT Gateways | 3 | ~$33 |
| EBS volumes | 4 | ~$7 |
| Application Load Balancer | 1 | ~$18 |
| Route53, ECR, S3, DynamoDB | — | ~$4 |
| **Total (with spot workers)** | | **~$188/month** |

---

## 🎯 Conclusion

This project is proof that production engineering is a series of deliberate decisions — not a series of tutorial steps.

Every component in this stack was chosen for a reason. Every failure I encountered was debugged from the bottom up. Every fix was applied with an understanding of why the failure happened, not just that it happened.

The infrastructure is modular, version-controlled, and reproducible. The deployment is automated and git-driven. The application is secure, highly available, and observable.

This is not just a deployed app. It is the foundation that a real company could use to serve real customers.

---

*Built by Amarachi Janefrancis — Cloud & DevOps Engineer*  
*Domain: [taskbymara.online](https://taskapp.taskbymara.online) | GitHub: [Cloudcrackamara](https://github.com/Cloudcrackamara)*
  
# TaskApp Architecture Documentation

## Project Overview
Production-grade cloud-native deployment of TaskApp (React frontend, 
Flask backend, PostgreSQL database) on AWS using Kubernetes, Terraform, 
and Kops with GitOps via ArgoCD.

## Live URLs
- Frontend: https://taskapp.taskbymara.online
- Backend API: https://taskapp.taskbymara.online/api
- Domain: taskbymara.online

---

## Infrastructure Design

### Network Architecture (VPC)
- **CIDR:** 10.0.0.0/16
- **Justification:** 65,536 IPs — sized for autoscaling and future 
  environments without requiring VPC redesign
- **Region:** us-east-1
- **Availability Zones:** us-east-1a, us-east-1b, us-east-1c

#### Subnet Layout
| Subnet | CIDR | AZ | Type | Purpose |
|--------|------|----|------|---------|
| public-1a | 10.0.1.0/24 | us-east-1a | Public | NAT Gateway + LB |
| public-1b | 10.0.2.0/24 | us-east-1b | Public | NAT Gateway + LB |
| public-1c | 10.0.3.0/24 | us-east-1c | Public | NAT Gateway + LB |
| private-1a | 10.0.10.0/24 | us-east-1a | Private | K8s nodes |
| private-1b | 10.0.11.0/24 | us-east-1b | Private | K8s nodes |
| private-1c | 10.0.12.0/24 | us-east-1c | Private | K8s nodes |

#### NAT Gateway Strategy
3 NAT Gateways deployed — one per AZ. If us-east-1a fails, 
us-east-1b and us-east-1c continue routing outbound traffic 
independently. This eliminates NAT as a single point of failure.

---

## Kubernetes Cluster

### Cluster Specifications
| Parameter | Value |
|-----------|-------|
| Tool | Kops (self-managed) |
| Version | 1.28.5 |
| CNI | Calico (NetworkPolicy support) |
| Topology | Private (zero public node IPs) |
| Control Plane | 3x t3.medium across 3 AZs |
| Workers | 3x t3.medium across 3 AZs |
| Bastion | 1x t3.micro (SSH access only) |
| Storage | EBS gp2 with CSI driver |
| Ingress | NGINX Ingress Controller |
| SSL | cert-manager + Let's Encrypt |

### High Availability Strategy
AZ Failure Scenario:

1 master lost → 2 remaining maintain etcd quorum (2/3 = majority)
1 worker lost → pods rescheduled on remaining 2 workers
1 NAT lost → other 2 AZs continue outbound traffic
Result: Zero downtime on single AZ failure

---

## Application Stack

### Components
| Component | Technology | Replicas | Memory |
|-----------|-----------|---------|--------|
| Frontend | React + nginx | 2 | 256Mi |
| Backend | Flask (Python) | 2 | 526Mi |
| Database | PostgreSQL 15.3 | 1 (StatefulSet) | 512Mi |

### Container Images
- Frontend: ECR `taskapp-frontend:v1.0.4` (IMMUTABLE tag)
- Backend: ECR `taskapp-backend:v1.0.0` (IMMUTABLE tag)
- Database: `postgres:15.3` (pinned version)

### Storage
- PostgreSQL uses EBS-backed PersistentVolumeClaim (10Gi)
- Retain policy — data survives pod deletion
- `subPath: pgdata` prevents mount directory conflicts

### Traffic Flow

User Browser
↓ HTTPS
Route53 DNS (taskbymara.online)
↓
AWS ELB (created by NGINX Ingress)
↓
NGINX Ingress Controller
↓ path: /api → Backend Service (port 5000)
↓ path: /    → Frontend Service (port 80)
↓
Application Pods (private subnets)
↓
PostgreSQL (StatefulSet, EBS volume)

---

## Infrastructure as Code

### Terraform Modules
| Module | Resources |
|--------|-----------|
| vpc | VPC, 6 subnets, 3 NAT GWs, routing tables, IGW |
| iam | IAM group, policies, Kops S3 state bucket |
| ecr | Frontend + backend ECR repos, lifecycle policies |
| dns | Route53 hosted zone for taskbymara.online |

### State Management
- **Remote State:** S3 bucket `taskapp-tfstate-amara`
- **State Locking:** DynamoDB table `taskapp-tf-lock`
- **Encryption:** AES256 at rest
- **Versioning:** Enabled (rollback capability)

---

## Security Model

### Network Security
- All K8s nodes in private subnets (no public IPs)
- NAT Gateways for outbound-only internet access
- Bastion host as only SSH entry point
- NGINX Ingress as only ingress point (ports 80/443)

### IAM Security
- No root account usage
- Dedicated `taskapp-kops-admins` group with least-privilege policies
- EC2 instance profiles (no hardcoded credentials)

### Secret Management
- Database credentials stored in Kubernetes Secrets
- Secrets never committed to Git in plaintext
- ECR repositories private with IMMUTABLE image tags

### SSL/TLS
- Let's Encrypt certificates via cert-manager
- Auto-renewal before expiry
- HTTP → HTTPS redirect enforced
- TLS 1.2/1.3 only

---

## GitOps (ArgoCD)
ArgoCD monitors the GitHub repository and automatically syncs 
any changes to k8s/base/ to the cluster.

- **Sync Status:** Automated
- **Self-Heal:** Enabled (reverts manual cluster changes)
- **Prune:** Enabled (removes deleted resources)
- **Repo:** https://github.com/Cloudcrackamara/TaskApp-Project


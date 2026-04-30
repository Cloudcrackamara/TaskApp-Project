# Monthly Cost Analysis

## AWS Resource Breakdown

| Resource | Count | Unit Price | Monthly Cost |
|----------|-------|------------|--------------|
| EC2 t3.medium (control plane) | 3 | $0.0416/hr | ~$90 |
| EC2 t3.medium (worker nodes) | 3 | $0.0416/hr | ~$90 |
| EC2 t3.micro (bastion) | 1 | $0.0104/hr | ~$8 |
| NAT Gateway | 3 | $0.045/hr | ~$33 |
| NAT Gateway data processing | - | $0.045/GB | ~$5 |
| EBS gp2 10Gi (postgres) | 1 | $0.10/GB/mo | ~$1 |
| EBS volumes (etcd + nodes) | 6 | $0.10/GB/mo | ~$6 |
| Application Load Balancer | 1 | $0.008/hr | ~$18 |
| Route53 Hosted Zone | 1 | $0.50/mo | ~$1 |
| ECR storage | 2 repos | $0.10/GB/mo | ~$1 |
| S3 (state + kops) | 2 buckets | $0.023/GB/mo | ~$1 |
| DynamoDB (state lock) | 1 table | PAY_PER_REQUEST | ~$0 |
| **Total Estimate** | | | **~$254/month** |

---

## Cost Optimization Implemented

### Spot Instances (Worker Nodes)
Worker nodes configured with mixed instance policy:
- Primary: t3a.medium (spot)
- Fallback: t3.medium (spot)
- Strategy: capacity-optimized

**Estimated savings:** ~60% on worker node costs (~$54/month saved)
**Optimized total:** ~$200/month

### ECR Lifecycle Policies
- Untagged images automatically deleted after 7 days
- Prevents storage cost accumulation

### S3 Lifecycle Rules
- Kops state older than 90 days moved to cheaper storage tier

---

## Cost Controls

### Budget Alert
- AWS Budget alert set at $100/month
- Email notification at 50% and 80% thresholds
- Prevents unexpected billing surprises

### Cleanup Script
```bash
bash scripts/destroy.sh
```
Destroys all resources when not in use. Running the cluster
only during active development saves ~$200/month.

---

## Cost vs Managed Services Comparison

| Option | Monthly Cost | Control |
|--------|-------------|---------|
| This setup (Kops) | ~$200 | Full control |
| AWS EKS equivalent | ~$280 | Managed control plane |
| AWS EKS + Fargate | ~$350+ | Fully managed |

**Decision:** Kops chosen for cost efficiency and full control,
which also satisfies the capstone learning objectives.
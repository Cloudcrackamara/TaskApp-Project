output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "route53_nameservers" {
  value       = module.dns.nameservers
  description = "Add these to Namecheap"
}

output "ecr_frontend_url" {
  value = module.ecr.frontend_repo_url
}

output "ecr_backend_url" {
  value = module.ecr.backend_repo_url
}

output "kops_state_bucket" {
  value = module.iam.kops_state_bucket
}
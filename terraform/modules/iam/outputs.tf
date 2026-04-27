output "kops_state_bucket" {
  value = aws_s3_bucket.kops_state.bucket
}

output "kops_admin_group" {
  value = aws_iam_group.kops_admin.name
}
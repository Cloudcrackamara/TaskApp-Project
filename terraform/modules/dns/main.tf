resource "aws_route53_zone" "main" {
  name = var.domain_name
  tags = {
    Project = "taskapp"
    Name    = var.domain_name
  }
}
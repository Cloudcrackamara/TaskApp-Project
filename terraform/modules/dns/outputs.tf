output "zone_id" {
  value = aws_route53_zone.main.zone_id
}

output "nameservers" {
  value       = aws_route53_zone.main.name_servers
  description = "Add these 4 to Namecheap custom DNS"
}
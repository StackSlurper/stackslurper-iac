output "public_ip" {
  description = "Public IP address of the backend EC2 instance"
  value       = aws_instance.backend_server.public_ip
}

output "route53_nameservers" {
  value       = aws_route53_zone.primary.name_servers
  description = "AWS Route 53 nameservers for Namecheap"
  # Note that we cannot use IaC here as there are requirements for Namecheap's API to prevent abuse:
  # - We’re sorry, you have not met the criteria to qualify for API access. To qualify, you must have:
  #   - Account balance of $50+
  #   - 20+ domains in your account
  #   - or purchases totaling $50+ within the last 2 years.
}
output "route53_zone_id" {
  value       = aws_route53_zone.primary.zone_id
  description = "AWS Route 53 zone ID for Namecheap"
}

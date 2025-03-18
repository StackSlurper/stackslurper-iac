output "terraform_user_access_key" {
  value     = module.iam.terraform_user_access_key
  sensitive = true
}

output "terraform_user_access_key_secret" {
  value     = module.iam.terraform_user_access_key_secret
  sensitive = true
}

output "public_ip" {
  description = "Public IP address of the backend EC2 instance"
  value       = module.backend_ec2.public_ip
}

output "route53_nameservers" {
  description = "AWS Route 53 nameservers for Namecheap"
  value       = module.backend_ec2.route53_nameservers
}

output "kms_key_arn" {
  description = "KMS Key ARN for Terraform Secrets"
  value       = module.kms.kms_key_arn
}

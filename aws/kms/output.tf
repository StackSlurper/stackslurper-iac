output "kms_key_arn" {
  description = "KMS Key ARN for Terraform Secrets"
  value       = aws_kms_key.terraform_secrets.arn
}

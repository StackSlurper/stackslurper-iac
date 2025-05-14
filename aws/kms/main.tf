
terraform {
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Create an AWS KMS Key for Encrypting Secrets
resource "aws_kms_key" "terraform_secrets" {
  description             = "Terraform Secrets Key"
  deletion_window_in_days = 7
}

# IAM Policy for KMS Access
resource "aws_iam_policy" "kms_access" {
  name        = "KMSDecryptAccess"
  description = "Allow encryption and decryption with Terraform Secrets KMS Key"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.terraform_secrets.arn
      }
    ]
  })
}

# ✅ Attach IAM Policy to Your IAM User (Replace with your AWS username)
resource "aws_iam_user_policy_attachment" "kms_user_attach" {
  user       = "terraform-user"
  policy_arn = aws_iam_policy.kms_access.arn
}

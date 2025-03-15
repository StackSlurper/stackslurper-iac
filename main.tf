module "iam" {
  source = "./aws/iam"
}

output "terraform_user_access_key" {
  value     = module.iam.terraform_user_access_key
  sensitive = true
}

output "terraform_user_access_key_secret" {
  value     = module.iam.terraform_user_access_key_secret
  sensitive = true
}

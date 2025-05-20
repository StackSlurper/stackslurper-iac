module "iam" {
  source = "./aws/iam"
}

module "backend_ec2" {
  source = "./aws/backend_ec2"
}

module "kms" {
  source = "./aws/kms"
}

module "email" {
  source  = "./aws/email"
  zone_id = module.backend_ec2.route53_zone_id
}

module "database" {
  source = "./aws/database"

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  # Optionally pass shared resources
  backend_security_group_id = module.backend_ec2.security_group_id
  subnets                   = data.aws_subnets.default.ids
}

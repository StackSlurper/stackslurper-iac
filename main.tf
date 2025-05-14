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

module "iam" {
  source = "./aws/iam"
}

module "backend_ec2" {
  source = "./aws/backend_ec2"
}

module "kms" {
  source = "./aws/kms"
}

locals {
  prefix = "${var.project_name}-${var.environment}"
  keypair = file("../../keypairs/zenith-kp.pub")

  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Thanos"
  }
}

resource "aws_key_pair" "bastion" {
  key_name = "zenith-kp"
  public_key = local.keypair
}

# Not Implemented
module "secrets" {
  source = "../../modules/secrets"
}

module "iam" {
  source = "../../modules/iam"

  environment = var.environment
  project_name = var.project_name
}

module "vpc" {
  source = "../../modules/vpc"

  prefix = var.prefix
  bastion_key_name = aws_key_pair.bastion.key_name
  bastion_instance_profile_name = module.iam.bastion_instance_profile_name
  bastion_instance_type = "t3.micro"
}

module "bastion" {
  source = "../../modules/ec2"

  prefix = local.prefix
  region = var.region
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0]
  instance_name = "bastion"
  instance_type = "t3.micro"
  key_name = aws_key_pair.bastion.key_name
  instance_profile_name = module.iam.bastion_instance_profile_name
}

module "s3" {
  source = "../../modules/s3"

  prefix = local.prefix
  web_static_bucket_allowed_headers = ["*"]
  web_static_bucket_allowed_methods = ["GET", "POST", "PUT", "DELETE", "HEAD"]
  web_static_bucket_allowed_origins = ["*"]
  web_static_bucket_expose_headers = []
  web_static_bucket_max_age_seconds = 3600
}

module "rds" {
  source = "../../modules/rds"
}

module "elasticache" {
  source = "../../modules/elasticache"
}

module "ecr" {
  source = "../../modules/ecr"
}

module "eks" {
  source = "../../modules/eks"
}

module "load_balancers" {
  source = "../../modules/load_balancers"
}

module "cloudfront" {
  source = "../../modules/cloudfront"
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"
}

module "route53" {
  source = "../../modules/route53"
}

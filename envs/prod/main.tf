locals {
  prefix  = "${var.project_name}-${var.environment}"
  keypair = file("../../keypairs/zenith-kp.pub")

  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Thanos"
  }
}

resource "aws_key_pair" "bastion" {
  key_name   = "zenith-kp"
  public_key = local.keypair
}

# Not Implemented
module "secrets" {
  source = "../../modules/secrets"
}

module "iam" {
  source = "../../modules/iam"

  environment  = var.environment
  project_name = var.project_name
}

module "vpc" {
  source = "../../modules/vpc"

  prefix                        = var.prefix
  bastion_key_name              = aws_key_pair.bastion.key_name
  bastion_instance_profile_name = module.iam.bastion_instance_profile_name
  bastion_instance_type         = "t3.micro"
}

module "bastion" {
  source = "../../modules/ec2"

  prefix                = local.prefix
  region                = var.region
  vpc_id                = module.vpc.vpc_id
  subnet_id             = module.vpc.public_subnet_ids[0]
  instance_name         = "bastion"
  instance_type         = "t3.micro"
  key_name              = aws_key_pair.bastion.key_name
  instance_profile_name = module.iam.bastion_instance_profile_name
}

module "s3" {
  source = "../../modules/s3"

  prefix                            = local.prefix
  web_static_bucket_allowed_headers = ["*"]
  web_static_bucket_allowed_methods = ["GET", "POST", "PUT", "DELETE", "HEAD"]
  web_static_bucket_allowed_origins = ["*"]
  web_static_bucket_expose_headers  = []
  web_static_bucket_max_age_seconds = 3600
}

module "rds" {
  source = "../../modules/rds"

  prefix       = local.prefix
  project_name = var.project_name
  environment  = var.environment
  name         = "zenith-rds"

  vpc_id     = module.vpc.vpc_id
  vpc_cidr   = module.vpc.vpc_cidr_block
  subnet_ids = module.vpc.protected_subnet_ids

  engine         = "mysql"
  engine_version = "8.0.42"
  database_name  = "zenith"

  instance_class        = "db.t3.medium"
  allocated_storage     = 30
  max_allocated_storage = 50
  storage_type          = "gp3"

  backup_window      = "00:00-03:00"
  maintenance_window = "sat:17:00-sat:19:00"

  master_username = "sigmoid"
  master_password = var.rds_master_password

  publicly_accessible        = false
  multi_az                   = true
  auto_minor_version_upgrade = true

  allow_ingress_from_vpc = true
  allowed_cidr_blocks    = var.rds_allowed_cidr_blocks
  allowed_security_group_ids = [
    module.vpc.bastion_security_group_id
  ]
}

module "elasticache" {
  source = "../../modules/elasticache"

  prefix       = local.prefix
  project_name = var.project_name
  environment  = var.environment
  name         = "zenith-cache"

  vpc_id     = module.vpc.vpc_id
  vpc_cidr   = module.vpc.vpc_cidr_block
  subnet_ids = module.vpc.protected_subnet_ids

  node_type      = "cache.t3.small"
  engine_version = "7.1"
  port           = 6379

  number_cache_clusters      = 2
  maintenance_window         = "sun:20:00-sun:21:00"
  snapshot_window            = "04:00-06:00"
  snapshot_retention_limit   = 7
  automatic_failover_enabled = true
  multi_az_enabled           = true

  auth_token = var.elasticache_auth_token

  allow_ingress_from_vpc = true
  allowed_cidr_blocks    = var.elasticache_allowed_cidr_blocks
  allowed_security_group_ids = [
    module.vpc.bastion_security_group_id
  ]
}

module "ecr" {
  source = "../../modules/ecr"

  project_name = var.project_name
  environment  = var.environment
  namespace    = var.prefix

  repositories = ["news", "frontend", "backend"]

  lifecycle_policy_keep_count = 10
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

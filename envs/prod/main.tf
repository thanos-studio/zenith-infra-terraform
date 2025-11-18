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

  project_name = var.project_name
  environment  = var.environment
  cluster_name = "zenith-eks"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_node_role_arn

  cluster_version            = "1.29"
  endpoint_private_access    = true
  endpoint_public_access     = true
  public_access_cidrs        = ["0.0.0.0/0"]
  node_instance_types        = ["c5.large"]
  node_desired_size          = 2
  node_min_size              = 2
  node_max_size              = 3
  node_capacity_type         = "ON_DEMAND"
  node_labels                = { app = "zenith" }
  enable_container_insights  = true
  cluster_log_retention_days = 30
}

module "load_balancers" {
  source = "../../modules/load_balancers"

  project_name      = var.project_name
  environment       = var.environment
  name              = "zenith-alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids

  allowed_ingress_cidrs     = ["0.0.0.0/0"]
  enable_http_listener      = true
  enable_https_listener     = false
  default_target_group_name = "frontend"

  target_groups = [
    {
      name                  = "frontend"
      port                  = 80
      protocol              = "HTTP"
      target_type           = "ip"
      health_check_path     = "/"
      health_check_interval = 30
      health_check_timeout  = 5
      healthy_threshold     = 5
      unhealthy_threshold   = 2
      health_check_matcher  = "200-399"
    },
    {
      name                  = "backend"
      port                  = 8080
      protocol              = "HTTP"
      target_type           = "ip"
      health_check_path     = "/health"
      health_check_interval = 30
      health_check_timeout  = 5
      healthy_threshold     = 5
      unhealthy_threshold   = 2
      health_check_matcher  = "200-399"
    },
    {
      name                  = "news"
      port                  = 8081
      protocol              = "HTTP"
      target_type           = "ip"
      health_check_path     = "/health"
      health_check_interval = 30
      health_check_timeout  = 5
      healthy_threshold     = 5
      unhealthy_threshold   = 2
      health_check_matcher  = "200-399"
    }
  ]
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

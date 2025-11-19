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

module "secrets" {
  source = "../../modules/secrets"

  project_name          = var.project_name
  environment           = var.environment
  mysql_master_password = var.rds_master_password
  enable_redis_secret   = var.enable_redis_secret
  redis_auth_token      = var.elasticache_auth_token
  enable_github_secret  = var.enable_github_secret
  github_token          = var.github_token
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
  bastion_instance_type         = var.bastion_instance_type
}

module "bastion" {
  source = "../../modules/ec2"

  prefix                = local.prefix
  region                = var.region
  vpc_id                = module.vpc.vpc_id
  subnet_id             = module.vpc.public_subnet_ids[0]
  instance_name         = "bastion"
  instance_type         = var.bastion_instance_type
  root_volume_size      = var.bastion_root_volume_size
  key_name              = aws_key_pair.bastion.key_name
  instance_profile_name = module.iam.bastion_instance_profile_name
}

module "s3" {
  source = "../../modules/s3"

  prefix                            = local.prefix
  web_static_bucket_allowed_headers = var.web_static_bucket_allowed_headers
  web_static_bucket_allowed_methods = var.web_static_bucket_allowed_methods
  web_static_bucket_allowed_origins = var.web_static_bucket_allowed_origins
  web_static_bucket_expose_headers  = var.web_static_bucket_expose_headers
  web_static_bucket_max_age_seconds = var.web_static_bucket_max_age_seconds
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
  engine_version = var.rds_engine_version
  database_name  = var.rds_database_name

  instance_class        = var.rds_instance_class
  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage
  storage_type          = var.rds_storage_type

  backup_window      = var.rds_backup_window
  maintenance_window = var.rds_maintenance_window

  master_username = "sigmoid"
  master_password = module.secrets.mysql_secret_value

  publicly_accessible        = var.rds_publicly_accessible
  multi_az                   = var.rds_multi_az
  auto_minor_version_upgrade = var.rds_auto_minor_version_upgrade

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

  node_type      = var.elasticache_node_type
  engine_version = var.elasticache_engine_version
  port           = var.elasticache_port

  number_cache_clusters      = var.elasticache_number_cache_clusters
  maintenance_window         = var.elasticache_maintenance_window
  snapshot_window            = var.elasticache_snapshot_window
  snapshot_retention_limit   = var.elasticache_snapshot_retention_limit
  automatic_failover_enabled = true
  multi_az_enabled           = true

  auth_token = module.secrets.redis_secret_value != null ? module.secrets.redis_secret_value : ""

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

  repositories = var.ecr_repositories

  lifecycle_policy_keep_count = 10
}

module "eks" {
  source = "../../modules/eks"

  project_name = var.project_name
  environment  = var.environment
  cluster_name = var.eks_cluster_name

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_node_role_arn

  cluster_version            = var.eks_cluster_version
  endpoint_private_access    = var.eks_endpoint_private_access
  endpoint_public_access     = var.eks_endpoint_public_access
  public_access_cidrs        = var.eks_public_access_cidrs
  node_instance_types        = var.eks_node_instance_types
  node_ami_type              = var.eks_node_ami_type
  node_desired_size          = var.eks_node_desired_size
  node_min_size              = var.eks_node_min_size
  node_max_size              = var.eks_node_max_size
  node_capacity_type         = var.eks_node_capacity_type
  node_labels                = var.eks_node_labels
  enable_container_insights  = var.eks_enable_container_insights
  cluster_log_retention_days = var.eks_cluster_log_retention_days
}

module "alb_app" {
  source = "../../modules/load_balancers"

  project_name      = var.project_name
  environment       = var.environment
  name              = var.app_alb_config.name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids

  allowed_ingress_cidrs     = var.app_alb_config.allowed_ingress_cidrs
  enable_http_listener      = var.app_alb_config.enable_http_listener
  enable_https_listener     = var.app_alb_config.enable_https_listener
  enable_waf                = var.app_alb_config.enable_waf
  default_target_group_name = var.app_alb_config.default_target_group_name
  target_groups             = var.app_alb_config.target_groups
}

module "alb_news" {
  source = "../../modules/load_balancers"

  project_name      = var.project_name
  environment       = var.environment
  name              = var.news_alb_config.name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids

  allowed_ingress_cidrs     = var.news_alb_config.allowed_ingress_cidrs
  enable_http_listener      = var.news_alb_config.enable_http_listener
  enable_https_listener     = var.news_alb_config.enable_https_listener
  enable_waf                = var.news_alb_config.enable_waf
  default_target_group_name = var.news_alb_config.default_target_group_name
  target_groups             = var.news_alb_config.target_groups
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  project_name = var.project_name
  environment  = var.environment
  region       = var.region

  eks_cluster_name    = module.eks.cluster_name
  eks_node_group_name = module.eks.node_group_name

  rds_instance_identifier          = module.rds.instance_identifier
  elasticache_replication_group_id = module.elasticache.replication_group_id

  load_balancers = [
    {
      name       = var.app_alb_config.name
      arn_suffix = module.alb_app.load_balancer_arn_suffix
    },
    {
      name       = var.news_alb_config.name
      arn_suffix = module.alb_news.load_balancer_arn_suffix
    }
  ]

  cloudfront_distribution_ids = var.cloudfront_distribution_ids

  service_target_groups = concat(
    [for name, suffix in module.alb_app.target_group_arn_suffixes : {
      name                     = "app-${name}"
      target_group_arn_suffix  = suffix
      load_balancer_arn_suffix = module.alb_app.load_balancer_arn_suffix
    }],
    [for name, suffix in module.alb_news.target_group_arn_suffixes : {
      name                     = "news-${name}"
      target_group_arn_suffix  = suffix
      load_balancer_arn_suffix = module.alb_news.load_balancer_arn_suffix
    }]
  )
}

module "route53" {
  source = "../../modules/route53"
}

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Thanos"
  }
}

module "secrets" {
  source = "../../modules/secrets"
}

module "iam" {
  source = "../../modules/iam"
}

module "vpc" {
  source = "../../modules/vpc"
}

module "bastion" {
  source = "../../modules/ec2"
}

module "s3" {
  source = "../../modules/s3"
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

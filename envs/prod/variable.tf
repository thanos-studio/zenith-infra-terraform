variable "environment" {
  description = "Deployment environment identifier (e.g. dev, staging, prod)."
  type        = string
}

variable "project_name" {
  description = "Human-friendly project name used for tagging."
  type        = string
}

variable "region" {
  description = "AWS region where the infrastructure is provisioned."
  type        = string
}

variable "prefix" {
  description = "Global resource prefix applied to all names."
  type        = string
}

variable "rds_master_password" {
  description = "Master password used for the production MySQL RDS instance."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.rds_master_password) >= 8
    error_message = "The RDS master password must be at least 8 characters long."
  }
}

variable "rds_allowed_cidr_blocks" {
  description = "Additional CIDR blocks that should have ingress to the RDS instance."
  type        = list(string)
  default     = []
}

variable "elasticache_auth_token" {
  description = "AUTH token protecting the Redis replication group (leave empty to disable)."
  type        = string
  default     = ""
  sensitive   = true

  validation {
    condition     = var.elasticache_auth_token == "" || length(var.elasticache_auth_token) >= 16
    error_message = "When set, the Redis auth token must be at least 16 characters long."
  }
}

variable "elasticache_allowed_cidr_blocks" {
  description = "Additional CIDR blocks that should have ingress to the Redis cluster."
  type        = list(string)
  default     = []
}

variable "enable_redis_secret" {
  description = "Set to true to create and manage the Redis auth token secret."
  type        = bool
}

variable "github_token" {
  description = "GitHub token stored in Secrets Manager when enable_github_secret is true."
  type        = string
  sensitive   = true
}

variable "enable_github_secret" {
  description = "Whether to create a GitHub token secret."
  type        = bool
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion host."
  type        = string
}

variable "bastion_root_volume_size" {
  description = "Root volume size (GiB) for the bastion host."
  type        = number
}

variable "web_static_bucket_allowed_headers" {
  description = "Allowed headers for the web static bucket CORS configuration."
  type        = list(string)
}

variable "web_static_bucket_allowed_methods" {
  description = "Allowed methods for the web static bucket CORS configuration."
  type        = list(string)
}

variable "web_static_bucket_allowed_origins" {
  description = "Allowed origins for the web static bucket CORS configuration."
  type        = list(string)
}

variable "web_static_bucket_expose_headers" {
  description = "Expose headers for the web static bucket CORS configuration."
  type        = list(string)
}

variable "web_static_bucket_max_age_seconds" {
  description = "Max age (seconds) for the web static bucket CORS configuration."
  type        = number
}

variable "rds_engine_version" {
  description = "MySQL engine version."
  type        = string
}

variable "rds_database_name" {
  description = "Database name created within the MySQL instance."
  type        = string
}

variable "rds_instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "rds_storage_type" {
  description = "Storage type for the RDS instance (gp2, gp3, io1, etc.)."
  type        = string
}

variable "rds_allocated_storage" {
  description = "Allocated storage (GiB) for the RDS instance."
  type        = number
}

variable "rds_max_allocated_storage" {
  description = "Maximum storage for the RDS instance."
  type        = number
}

variable "rds_backup_window" {
  description = "Preferred backup window for the MySQL instance."
  type        = string
}

variable "rds_maintenance_window" {
  description = "Preferred maintenance window for the MySQL instance."
  type        = string
}

variable "rds_publicly_accessible" {
  description = "Whether the MySQL instance is publicly accessible."
  type        = bool
}

variable "rds_multi_az" {
  description = "Whether to deploy the RDS instance in multiple AZs."
  type        = bool
}

variable "rds_auto_minor_version_upgrade" {
  description = "Toggle automatic minor version upgrades."
  type        = bool
}

variable "elasticache_node_type" {
  description = "Instance type for the Redis nodes."
  type        = string
}

variable "elasticache_engine_version" {
  description = "Redis engine version."
  type        = string
}

variable "elasticache_port" {
  description = "Port exposed by Redis."
  type        = number
}

variable "elasticache_number_cache_clusters" {
  description = "Number of cache nodes in the replication group."
  type        = number
}

variable "elasticache_maintenance_window" {
  description = "Preferred maintenance window for Redis."
  type        = string
}

variable "elasticache_snapshot_window" {
  description = "Preferred snapshot window for Redis."
  type        = string
}

variable "elasticache_snapshot_retention_limit" {
  description = "Snapshot retention (days) for Redis."
  type        = number
}

variable "ecr_repositories" {
  description = "List of ECR repositories to create."
  type        = list(string)
}

variable "eks_cluster_name" {
  description = "Name assigned to the EKS cluster."
  type        = string
}

variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS control plane."
  type        = string
}

variable "eks_endpoint_private_access" {
  description = "Enable private access for the EKS API server."
  type        = bool
}

variable "eks_endpoint_public_access" {
  description = "Enable public access for the EKS API server."
  type        = bool
}

variable "eks_public_access_cidrs" {
  description = "CIDR blocks permitted to reach the public EKS endpoint."
  type        = list(string)
}

variable "eks_node_instance_types" {
  description = "Instance types for the managed node group."
  type        = list(string)
}

variable "eks_node_ami_type" {
  description = "AMI type used by the EKS managed node group."
  type        = string
}

variable "eks_node_desired_size" {
  description = "Desired node count for the managed node group."
  type        = number
}

variable "eks_node_min_size" {
  description = "Minimum node count for the managed node group."
  type        = number
}

variable "eks_node_max_size" {
  description = "Maximum node count for the managed node group."
  type        = number
}

variable "eks_node_capacity_type" {
  description = "Capacity type for the managed node group."
  type        = string
}

variable "eks_node_labels" {
  description = "Kubernetes labels applied to the EKS managed nodes."
  type        = map(string)
}

variable "eks_enable_container_insights" {
  description = "Enable CloudWatch Container Insights."
  type        = bool
}

variable "eks_cluster_log_retention_days" {
  description = "Log retention (days) for the EKS control plane logs."
  type        = number
}

variable "app_alb_config" {
  description = "Configuration for the application ALB."
  type = object({
    name                      = string
    allowed_ingress_cidrs     = list(string)
    enable_http_listener      = bool
    enable_https_listener     = bool
    enable_waf                = bool
    default_target_group_name = string
    target_groups = list(object({
      name                  = string
      port                  = number
      protocol              = string
      target_type           = string
      health_check_path     = string
      health_check_interval = number
      health_check_timeout  = number
      healthy_threshold     = number
      unhealthy_threshold   = number
      health_check_matcher  = string
    }))
  })
}

variable "news_alb_config" {
  description = "Configuration for the news ALB."
  type = object({
    name                      = string
    allowed_ingress_cidrs     = list(string)
    enable_http_listener      = bool
    enable_https_listener     = bool
    enable_waf                = bool
    default_target_group_name = string
    target_groups = list(object({
      name                  = string
      port                  = number
      protocol              = string
      target_type           = string
      health_check_path     = string
      health_check_interval = number
      health_check_timeout  = number
      healthy_threshold     = number
      unhealthy_threshold   = number
      health_check_matcher  = string
    }))
  })
}

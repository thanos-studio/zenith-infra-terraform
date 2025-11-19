variable "project_name" {
  description = "Project name used for tagging and dashboard naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment identifier (e.g., dev, staging, prod)."
  type        = string
}

variable "region" {
  description = "AWS region where the core workloads are deployed."
  type        = string
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster observed by the dashboards."
  type        = string
}

variable "eks_node_group_name" {
  description = "Name of the primary EKS managed node group."
  type        = string
}

variable "rds_instance_identifier" {
  description = "Identifier of the RDS instance to monitor."
  type        = string
}

variable "elasticache_replication_group_id" {
  description = "Replication group identifier for the ElastiCache cluster."
  type        = string
}

variable "load_balancers" {
  description = "List of load balancers to visualize (name + ARN suffix)."
  type = list(object({
    name       = string
    arn_suffix = string
  }))
  default = []
}

variable "cloudfront_distribution_ids" {
  description = "CloudFront distribution IDs to include in the edge dashboard."
  type        = list(string)
  default     = []
}

variable "cloudfront_region" {
  description = "Region used for CloudFront metrics (must stay us-east-1/Global)."
  type        = string
  default     = "us-east-1"
}

variable "service_target_groups" {
  description = "Target groups (and owning load balancer) that represent application services."
  type = list(object({
    name                     = string
    target_group_arn_suffix  = string
    load_balancer_arn_suffix = string
  }))
  default = []
}

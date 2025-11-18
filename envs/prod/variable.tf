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

variable "project_name" {
  description = "Project name used when deriving secret names and tags."
  type        = string
}

variable "environment" {
  description = "Environment identifier."
  type        = string
}

variable "mysql_master_password" {
  description = "Master password that will be stored in Secrets Manager for MySQL."
  type        = string
  sensitive   = true
}

variable "enable_redis_secret" {
  description = "Whether to create a Redis (ElastiCache) auth token secret."
  type        = bool
  default     = false
}

variable "redis_auth_token" {
  description = "Redis auth token stored in Secrets Manager when enable_redis_secret is true."
  type        = string
  sensitive   = true
  default     = ""
}

variable "enable_github_secret" {
  description = "Whether to create a GitHub token secret."
  type        = bool
  default     = false
}

variable "github_token" {
  description = "GitHub personal access token stored in Secrets Manager when enable_github_secret is true."
  type        = string
  sensitive   = true
  default     = ""
}

variable "prefix" {
  description = "Prefix included in resource names for organizational consistency."
  type        = string
}

variable "project_name" {
  description = "Project name used for tagging."
  type        = string
}

variable "environment" {
  description = "Deployment environment identifier (e.g. dev, staging, prod)."
  type        = string
}

variable "name" {
  description = "Friendly identifier appended to resource names (must start with a letter)."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]+$", var.name))
    error_message = "The name must start with a letter and contain only letters, numbers, or hyphens."
  }
}

variable "vpc_id" {
  description = "Identifier of the VPC hosting the cache cluster."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC, used when allow_ingress_from_vpc is true."
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Protected subnets used by the ElastiCache subnet group (minimum of two)."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Provide at least two subnet identifiers for the ElastiCache subnet group."
  }
}

variable "node_type" {
  description = "Cache node instance type (e.g. cache.t3.small)."
  type        = string
  default     = "cache.t3.small"
}

variable "engine_version" {
  description = "Redis engine version."
  type        = string
  default     = "7.1"
}

variable "port" {
  description = "Port exposed by the Redis replication group."
  type        = number
  default     = 6379

  validation {
    condition     = var.port > 0 && var.port <= 65535
    error_message = "Port must be between 1 and 65535."
  }
}

variable "number_cache_clusters" {
  description = "Total number of cache nodes (1 primary + replicas)."
  type        = number
  default     = 2

  validation {
    condition     = var.number_cache_clusters >= 1 && var.number_cache_clusters <= 6
    error_message = "Number of cache clusters must be between 1 and 6."
  }
}

variable "multi_az_enabled" {
  description = "Distribute nodes across multiple AZs."
  type        = bool
  default     = true
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover (requires at least two cache clusters)."
  type        = bool
  default     = true

  validation {
    condition     = var.automatic_failover_enabled == false || var.number_cache_clusters >= 2
    error_message = "Automatic failover requires number_cache_clusters to be at least 2."
  }
}

variable "at_rest_encryption_enabled" {
  description = "Enable encryption at rest."
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Enable in-transit encryption."
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Apply modifications immediately (may cause disruption)."
  type        = bool
  default     = true
}

variable "maintenance_window" {
  description = "Preferred maintenance window (ddd:hh24:mi-ddd:hh24:mi). Leave empty to let AWS decide."
  type        = string
  default     = ""
}

variable "snapshot_window" {
  description = "Preferred daily snapshot window (hh24:mi-hh24:mi). Leave empty to let AWS decide."
  type        = string
  default     = ""
}

variable "snapshot_retention_limit" {
  description = "Number of days to retain automatic snapshots."
  type        = number
  default     = 7

  validation {
    condition     = var.snapshot_retention_limit >= 0 && var.snapshot_retention_limit <= 35
    error_message = "Snapshot retention must be between 0 and 35 days."
  }
}

variable "auth_token" {
  description = "Redis AUTH token used when transit encryption is enabled."
  type        = string
  default     = ""
  sensitive   = true

  validation {
    condition     = var.auth_token == "" || (length(var.auth_token) >= 16 && var.transit_encryption_enabled)
    error_message = "Auth token must be empty or at least 16 characters long with transit encryption enabled."
  }
}

variable "allow_ingress_from_vpc" {
  description = "Automatically allow inbound traffic from the VPC CIDR."
  type        = bool
  default     = true
}

variable "allowed_cidr_blocks" {
  description = "Additional CIDR blocks granted ingress to the cache."
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security groups granted ingress to the cache."
  type        = list(string)
  default     = []
}

variable "additional_security_group_ids" {
  description = "Additional security groups attached to the cluster ENIs."
  type        = list(string)
  default     = []
}

variable "parameter_group_family" {
  description = "Redis parameter group family."
  type        = string
  default     = "redis7"
}

variable "parameters" {
  description = "Custom parameter overrides."
  type = list(object({
    name  = string
    value = string
  }))
  default = []

  validation {
    condition     = length(var.parameters) == 0 || var.parameter_group_family != ""
    error_message = "Parameter overrides require parameter_group_family to be set."
  }
}

variable "tags" {
  description = "Additional tags merged into every created resource."
  type        = map(string)
  default     = {}
}

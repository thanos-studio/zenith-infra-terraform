variable "project_name" {
  description = "Project name used when deriving identifiers and tags."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "cluster_name" {
  description = "Friendly cluster identifier appended to resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]+$", var.cluster_name))
    error_message = "Cluster name must start with a letter and contain only letters, numbers, or hyphens."
  }
}

variable "cluster_version" {
  description = "EKS control plane Kubernetes version."
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "Identifier of the VPC where the cluster resides."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs used for the cluster and node groups."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "Provide at least two private subnet IDs."
  }
}

variable "cluster_role_arn" {
  description = "IAM role ARN assumed by the EKS control plane."
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN assumed by the EKS managed node group instances."
  type        = string
}

variable "endpoint_private_access" {
  description = "Enable private API server access from within the VPC."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Expose the API server publicly."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDR blocks permitted to reach the public API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_log_retention_days" {
  description = "Retention (days) for the CloudWatch log group that stores control plane logs."
  type        = number
  default     = 30
}

variable "node_instance_types" {
  description = "Instance types used by the managed node group."
  type        = list(string)
  default     = ["c5.large"]
}

variable "node_desired_size" {
  description = "Desired size of the managed node group."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum instance count for the managed node group."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum instance count for the managed node group."
  type        = number
  default     = 3
}

variable "node_disk_size" {
  description = "EBS volume size (GiB) for each worker node."
  type        = number
  default     = 50
}

variable "node_capacity_type" {
  description = "Capacity type for the node group (ON_DEMAND or SPOT)."
  type        = string
  default     = "ON_DEMAND"
}

variable "node_labels" {
  description = "Kubernetes labels applied to the node group."
  type        = map(string)
  default = {
    app = "zenith"
  }
}

variable "enable_container_insights" {
  description = "Deploy the Amazon CloudWatch Observability add-on for Container Insights."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags merged into every created resource."
  type        = map(string)
  default     = {}
}

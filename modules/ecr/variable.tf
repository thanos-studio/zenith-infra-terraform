variable "project_name" {
  description = "Project name used for tagging."
  type        = string
}

variable "environment" {
  description = "Deployment environment identifier."
  type        = string
}

variable "namespace" {
  description = "ECR repository namespace (prefix before the slash)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]+(?:[._\\/-][a-z0-9]+)*$", var.namespace))
    error_message = "Namespace must contain only lowercase alphanumeric characters plus separators . _ - /."
  }
}

variable "repositories" {
  description = "List of repository names to create beneath the namespace."
  type        = list(string)
  default     = ["news", "frontend", "backend"]

  validation {
    condition     = length(var.repositories) > 0
    error_message = "Provide at least one repository name."
  }
}

variable "scan_on_push" {
  description = "Enable image scanning on push."
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "Allow repository deletion even if images remain."
  type        = bool
  default     = false
}

variable "lifecycle_policy_keep_count" {
  description = "Number of recent images to retain via the lifecycle policy."
  type        = number
  default     = 10

  validation {
    condition     = var.lifecycle_policy_keep_count >= 1
    error_message = "Lifecycle policy must retain at least one image."
  }
}

variable "tags" {
  description = "Additional tags merged into ECR repositories."
  type        = map(string)
  default     = {}
}

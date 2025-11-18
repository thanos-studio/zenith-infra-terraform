variable "project_name" {
  description = "Project name used for tagging."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "name" {
  description = "Friendly identifier appended to the load balancer name."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]+$", var.name))
    error_message = "Name must start with a letter and contain only letters, numbers, or hyphens."
  }
}

variable "vpc_id" {
  description = "VPC that hosts the load balancer."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs that span the load balancer."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "Provide at least two public subnets for the load balancer."
  }
}

variable "internal" {
  description = "Whether the ALB is internal. Defaults to false (public)."
  type        = bool
  default     = false
}

variable "allowed_ingress_cidrs" {
  description = "CIDR blocks permitted to reach the ALB listeners."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_http_listener" {
  description = "Provision an HTTP listener on port 80."
  type        = bool
  default     = true
}

variable "enable_https_listener" {
  description = "Provision an HTTPS listener on port 443."
  type        = bool
  default     = false
}

variable "https_certificate_arn" {
  description = "ACM certificate ARN required when HTTPS listener is enabled."
  type        = string
  default     = ""

  validation {
    condition     = var.enable_https_listener == false || var.https_certificate_arn != ""
    error_message = "When enable_https_listener is true, https_certificate_arn must be provided."
  }
}

variable "target_groups" {
  description = "List of target groups provisioned for downstream services."
  type = list(object({
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
  default = [
    {
      name                  = "default"
      port                  = 80
      protocol              = "HTTP"
      target_type           = "ip"
      health_check_path     = "/"
      health_check_interval = 30
      health_check_timeout  = 5
      healthy_threshold     = 5
      unhealthy_threshold   = 2
      health_check_matcher  = "200"
    }
  ]

  validation {
    condition     = length(var.target_groups) > 0
    error_message = "At least one target group must be defined."
  }
}

variable "default_target_group_name" {
  description = "Target group name used as the default action for listeners."
  type        = string
  default     = "default"
}

variable "tags" {
  description = "Additional tags merged into resources."
  type        = map(string)
  default     = {}
}

variable "enable_waf" {
  description = "Create and associate a WAFv2 web ACL with the ALB."
  type        = bool
  default     = false
}

variable "waf_managed_rule_groups" {
  description = "Managed rule groups applied to the WAF web ACL when enabled."
  type = list(object({
    name        = string
    vendor_name = string
    priority    = number
    version     = optional(string)
  }))
  default = [
    {
      name        = "AWSManagedRulesCommonRuleSet"
      vendor_name = "AWS"
      priority    = 1
    }
  ]

  validation {
    condition     = var.enable_waf == false || length(var.waf_managed_rule_groups) > 0
    error_message = "At least one managed rule group must be supplied when enable_waf is true."
  }
}

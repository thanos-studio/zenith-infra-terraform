variable "prefix" {
  description = "Base prefix applied to CloudFront resources and tags."
  type        = string
}

variable "origin_domain_name" {
  description = "Domain name for the S3 origin backing the /static path (e.g. bucket.s3.amazonaws.com)."
  type        = string
}

variable "origin_id" {
  description = "Optional explicit origin ID. Defaults to <prefix>-s3-origin."
  type        = string
  default     = ""
}

variable "alb_origin_domain_name" {
  description = "Domain name for the Application Load Balancer origin."
  type        = string
}

variable "alb_origin_id" {
  description = "Optional explicit origin ID for the ALB. Defaults to <prefix>-alb-origin."
  type        = string
  default     = ""
}

variable "alb_origin_http_port" {
  description = "HTTP port used by the ALB origin."
  type        = number
  default     = 80
}

variable "alb_origin_https_port" {
  description = "HTTPS port used by the ALB origin."
  type        = number
  default     = 443
}

variable "alb_origin_protocol_policy" {
  description = "Protocol policy CloudFront should use when connecting to the ALB origin."
  type        = string
  default     = "https-only"

  validation {
    condition     = contains(["http-only", "match-viewer", "https-only"], var.alb_origin_protocol_policy)
    error_message = "alb_origin_protocol_policy must be one of http-only, https-only, or match-viewer."
  }
}

variable "alb_origin_ssl_protocols" {
  description = "List of SSL protocols supported by the ALB origin."
  type        = list(string)
  default     = ["TLSv1.2"]
}

variable "static_path_pattern" {
  description = "Path pattern that should be served from the S3 origin."
  type        = string
  default     = "/static/*"
}

variable "comment" {
  description = "Custom comment applied to the CloudFront distribution."
  type        = string
  default     = ""
}

variable "enabled" {
  description = "Whether the distribution is enabled."
  type        = bool
  default     = true
}

variable "enable_ipv6" {
  description = "Enable IPv6 for the distribution."
  type        = bool
  default     = true
}

variable "aliases" {
  description = "List of CNAMEs associated with the distribution."
  type        = list(string)
  default     = []
}

variable "default_root_object" {
  description = "Default root object (landing file) for the distribution."
  type        = string
  default     = "index.html"
}

variable "http_version" {
  description = "HTTP version supported by the distribution."
  type        = string
  default     = "http2"
}

variable "price_class" {
  description = "CloudFront price class."
  type        = string
  default     = "PriceClass_All"
}

variable "web_acl_id" {
  description = "Optional associated WAF web ACL ID."
  type        = string
  default     = ""
}

variable "default_cache_allowed_methods" {
  description = "HTTP methods allowed by the default cache behavior."
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "default_cache_cached_methods" {
  description = "HTTP methods cached by the default cache behavior."
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "viewer_protocol_policy" {
  description = "Viewer protocol policy for the default cache behavior."
  type        = string
  default     = "redirect-to-https"

  validation {
    condition     = contains(["allow-all", "https-only", "redirect-to-https"], var.viewer_protocol_policy)
    error_message = "viewer_protocol_policy must be one of allow-all, https-only, or redirect-to-https."
  }
}

variable "compress" {
  description = "Enable automatic compression for certain file types."
  type        = bool
  default     = true
}

variable "min_ttl" {
  description = "Minimum TTL for the default cache behavior."
  type        = number
  default     = 0
}

variable "default_ttl" {
  description = "Default TTL for cached objects."
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "Maximum TTL for cached objects."
  type        = number
  default     = 86400
}

variable "forward_query_string" {
  description = "Forward query strings to the origin."
  type        = bool
  default     = false
}

variable "forward_query_string_cache_keys" {
  description = "Additional cache keys for when query strings are forwarded."
  type        = list(string)
  default     = []
}

variable "forward_cookies" {
  description = "Cookie forwarding strategy for the default cache behavior."
  type        = string
  default     = "none"

  validation {
    condition     = contains(["none", "all", "whitelist"], var.forward_cookies)
    error_message = "forward_cookies must be one of none, all, or whitelist."
  }
}

variable "forward_cookie_names" {
  description = "Cookie names forwarded when forward_cookies is whitelist."
  type        = list(string)
  default     = []
}

variable "forward_headers" {
  description = "Custom headers forwarded to the origin."
  type        = list(string)
  default     = []
}

variable "geo_restriction_type" {
  description = "Type of geo restriction (none, whitelist, blacklist)."
  type        = string
  default     = "none"

  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.geo_restriction_type)
    error_message = "geo_restriction_type must be one of none, whitelist, or blacklist."
  }
}

variable "geo_restriction_locations" {
  description = "List of country codes used by the geo restriction."
  type        = list(string)
  default     = []
}

variable "logging_bucket" {
  description = "S3 bucket (in bucket.s3.amazonaws.com form) that receives logs."
  type        = string
  default     = ""
}

variable "logging_prefix" {
  description = "Log object prefix when logging is enabled."
  type        = string
  default     = ""
}

variable "logging_include_cookies" {
  description = "Include cookies in the access logs."
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN (in us-east-1) for custom domains. Leave empty to use the default certificate."
  type        = string
  default     = ""
}

variable "minimum_protocol_version" {
  description = "Minimum TLS protocol version when using a custom certificate."
  type        = string
  default     = "TLSv1.2_2021"
}

variable "tags" {
  description = "Additional tags to apply to the distribution."
  type        = map(string)
  default     = {}
}

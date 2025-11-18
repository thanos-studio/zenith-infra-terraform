variable "prefix" {
  description = "The prefix for the S3 buckets"
  type        = string
}

variable "web_static_bucket_allowed_headers" {
  description = "The allowed headers for the S3 bucket"
  type        = list(string)
}

variable "web_static_bucket_allowed_methods" {
  description = "The allowed methods for the S3 bucket"
  type        = list(string)
}

variable "web_static_bucket_allowed_origins" {
  description = "The allowed origins for the S3 bucket"
  type        = list(string)
}

variable "web_static_bucket_expose_headers" {
  description = "The expose headers for the S3 bucket"
  type        = list(string)
}

variable "web_static_bucket_max_age_seconds" {
  description = "The max age seconds for the S3 bucket"
  type        = number
}
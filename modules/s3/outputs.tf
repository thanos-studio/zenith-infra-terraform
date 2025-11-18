output "web_static_bucket_name" {
  description = "Name of the S3 bucket serving static web assets."
  value       = aws_s3_bucket.web_static_bucket.bucket
}

output "web_static_bucket_arn" {
  description = "ARN of the static web bucket."
  value       = aws_s3_bucket.web_static_bucket.arn
}

output "web_static_bucket_domain_name" {
  description = "Domain name of the static web bucket."
  value       = aws_s3_bucket.web_static_bucket.bucket_regional_domain_name
}

output "app_data_bucket_name" {
  description = "Name of the S3 bucket used for application data."
  value       = aws_s3_bucket.app_data_bucket.bucket
}

output "app_data_bucket_arn" {
  description = "ARN of the application data bucket."
  value       = aws_s3_bucket.app_data_bucket.arn
}

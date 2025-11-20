output "distribution_id" {
  description = "ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  description = "ARN of the CloudFront distribution."
  value       = aws_cloudfront_distribution.this.arn
}

output "distribution_domain_name" {
  description = "Domain name assigned by CloudFront."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "hosted_zone_id" {
  description = "Route53 hosted zone ID for the CloudFront distribution."
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

output "origin_access_identity" {
  description = "ID of the origin access identity created for the distribution."
  value       = aws_cloudfront_origin_access_identity.this.id
}

output "load_balancer_arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.main.arn
}

output "load_balancer_dns_name" {
  description = "DNS name of the ALB."
  value       = aws_lb.main.dns_name
}

output "load_balancer_zone_id" {
  description = "Route53 zone ID for the ALB DNS name."
  value       = aws_lb.main.zone_id
}

output "load_balancer_arn_suffix" {
  description = "ARN suffix (LoadBalancer dimension value) for the ALB."
  value       = aws_lb.main.arn_suffix
}

output "security_group_id" {
  description = "Security group protecting the ALB."
  value       = aws_security_group.alb.id
}

output "target_group_arns" {
  description = "Map of target group names to their ARNs."
  value       = { for name, tg in aws_lb_target_group.main : name => tg.arn }
}

output "target_group_arn_suffixes" {
  description = "Map of target group names to their ARN suffixes (TargetGroup dimension values)."
  value       = { for name, tg in aws_lb_target_group.main : name => tg.arn_suffix }
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener (null when disabled)."
  value       = length(aws_lb_listener.http) > 0 ? aws_lb_listener.http[0].arn : null
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener (null when disabled)."
  value       = length(aws_lb_listener.https) > 0 ? aws_lb_listener.https[0].arn : null
}

output "waf_arn" {
  description = "ARN of the associated WAFv2 web ACL (null when disabled)."
  value       = length(aws_wafv2_web_acl.this) > 0 ? aws_wafv2_web_acl.this[0].arn : null
}

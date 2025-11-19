output "mysql_secret_arn" {
  description = "ARN of the MySQL master password secret."
  value       = aws_secretsmanager_secret.mysql.arn
}

output "mysql_secret_name" {
  description = "Name of the MySQL master password secret."
  value       = aws_secretsmanager_secret.mysql.name
}

output "mysql_secret_value" {
  description = "JSON value of the MySQL database secret."
  value       = aws_secretsmanager_secret_version.mysql.secret_string
  sensitive   = true
}

output "mysql_password" {
  description = "MySQL master password (for RDS module usage)."
  value       = var.mysql_master_password
  sensitive   = true
}

output "redis_secret_arn" {
  description = "ARN of the Redis auth token secret (null when disabled)."
  value       = var.enable_redis_secret ? aws_secretsmanager_secret.redis[0].arn : null
}

output "redis_secret_name" {
  description = "Name of the Redis auth token secret (null when disabled)."
  value       = var.enable_redis_secret ? aws_secretsmanager_secret.redis[0].name : null
}

output "redis_secret_value" {
  description = "Value of the Redis auth token secret (null when disabled)."
  value       = var.enable_redis_secret ? aws_secretsmanager_secret_version.redis[0].secret_string : null
  sensitive   = true
}

output "github_secret_arn" {
  description = "ARN of the GitHub token secret (null when disabled)."
  value       = var.enable_github_secret ? aws_secretsmanager_secret.github[0].arn : null
}

output "github_secret_name" {
  description = "Name of the GitHub token secret (null when disabled)."
  value       = var.enable_github_secret ? aws_secretsmanager_secret.github[0].name : null
}

output "github_secret_value" {
  description = "Value of the GitHub token secret (null when disabled)."
  value       = var.enable_github_secret ? aws_secretsmanager_secret_version.github[0].secret_string : null
  sensitive   = true
}

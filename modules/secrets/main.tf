locals {
  prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Sigmoid"
  }
}

### --------------------------------------------------
### MySQL Secret (always created)
### --------------------------------------------------
resource "aws_secretsmanager_secret" "mysql" {
  name                    = "${local.prefix}-mysql"
  description             = "Database credentials for the ${local.prefix} MySQL database"
  recovery_window_in_days = 0

  tags = merge(local.common_tags, {
    SecretType = "mysql"
  })
}

resource "aws_secretsmanager_secret_version" "mysql" {
  secret_id = aws_secretsmanager_secret.mysql.id
  secret_string = jsonencode({
    DB_USER     = var.mysql_master_username
    DB_PASSWORD = var.mysql_master_password
    DB_URL      = var.mysql_endpoint
  })
}

### --------------------------------------------------
### Redis Secret (optional)
### --------------------------------------------------
resource "aws_secretsmanager_secret" "redis" {
  count                   = var.enable_redis_secret ? 1 : 0
  name                    = "${local.prefix}-redis"
  description             = "Redis credentials for the ${local.prefix} ElastiCache cluster"
  recovery_window_in_days = 0

  tags = merge(local.common_tags, {
    SecretType = "redis"
  })
}

resource "aws_secretsmanager_secret_version" "redis" {
  count     = var.enable_redis_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.redis[0].id
  secret_string = jsonencode({
    REDIS_AUTH_TOKEN = var.redis_auth_token
    REDIS_ENDPOINT   = var.redis_endpoint
  })
}

### --------------------------------------------------
### GitHub Secret (optional)
### --------------------------------------------------
resource "aws_secretsmanager_secret" "github" {
  count                   = var.enable_github_secret ? 1 : 0
  name                    = "${local.prefix}-github"
  description             = "GitHub token for the ${local.prefix} deployment automation"
  recovery_window_in_days = 0

  tags = merge(local.common_tags, {
    SecretType = "github"
  })
}

resource "aws_secretsmanager_secret_version" "github" {
  count     = var.enable_github_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.github[0].id
  secret_string = jsonencode({
    GITHUB_TOKEN = var.github_token
  })
}

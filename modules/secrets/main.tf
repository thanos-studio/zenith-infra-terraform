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
  description             = "Master password for the ${local.prefix} MySQL database"
  recovery_window_in_days = 0

  tags = merge(local.common_tags, {
    SecretType = "mysql"
  })
}

resource "aws_secretsmanager_secret_version" "mysql" {
  secret_id     = aws_secretsmanager_secret.mysql.id
  secret_string = var.mysql_master_password
}

### --------------------------------------------------
### Redis Secret (optional)
### --------------------------------------------------
resource "aws_secretsmanager_secret" "redis" {
  count                   = var.enable_redis_secret ? 1 : 0
  name                    = "${local.prefix}-redis-authtoken"
  description             = "Auth token for the ${local.prefix} Redis cluster"
  recovery_window_in_days = 0

  tags = merge(local.common_tags, {
    SecretType = "redis"
  })
}

resource "aws_secretsmanager_secret_version" "redis" {
  count         = var.enable_redis_secret ? 1 : 0
  secret_id     = aws_secretsmanager_secret.redis[0].id
  secret_string = var.redis_auth_token
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
  count         = var.enable_github_secret ? 1 : 0
  secret_id     = aws_secretsmanager_secret.github[0].id
  secret_string = var.github_token
}

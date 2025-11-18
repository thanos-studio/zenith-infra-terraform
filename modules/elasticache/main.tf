locals {
  identifier_source = join("-", compact([var.prefix, var.project_name, var.environment, var.name]))
  identifier        = substr(replace(lower(local.identifier_source), "_", "-"), 0, 40)

  subnet_group_name    = substr("${local.identifier}-subnets", 0, 255)
  parameter_group_name = substr("${local.identifier}-params", 0, 255)

  allowed_cidr_blocks = distinct(concat(
    var.allow_ingress_from_vpc && var.vpc_cidr != "" ? [var.vpc_cidr] : [],
    var.allowed_cidr_blocks
  ))

  ingress_rules = concat(
    [for cidr in local.allowed_cidr_blocks : {
      description     = "Ingress from ${cidr}"
      cidr_blocks     = [cidr]
      security_groups = []
    }],
    [for sg in var.allowed_security_group_ids : {
      description     = "Ingress from ${sg}"
      cidr_blocks     = []
      security_groups = [sg]
    }]
  )

  tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Sigmoid"
    },
    var.tags,
    {
      Name = local.identifier
    }
  )

  maintenance_window = var.maintenance_window != "" ? var.maintenance_window : null
  snapshot_window    = var.snapshot_window != "" ? var.snapshot_window : null
  auth_token         = var.auth_token != "" ? var.auth_token : null
}

### --------------------------------------------------
### Security Group
### --------------------------------------------------
resource "aws_security_group" "main" {
  name        = "${local.identifier}-sg"
  description = "Security group for ${local.identifier} ElastiCache replication group"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      description     = ingress.value.description
      from_port       = var.port
      to_port         = var.port
      protocol        = "tcp"
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${local.identifier}-sg" })
}

### --------------------------------------------------
### Subnet & Parameter Groups
### --------------------------------------------------
resource "aws_elasticache_subnet_group" "main" {
  name        = local.subnet_group_name
  description = "Subnets for ${local.identifier} Redis cluster"
  subnet_ids  = var.subnet_ids

  tags = merge(local.tags, { Name = local.subnet_group_name })
}

resource "aws_elasticache_parameter_group" "main" {
  count       = var.parameter_group_family != "" ? 1 : 0
  name        = local.parameter_group_name
  family      = var.parameter_group_family
  description = "Parameters for ${local.identifier} Redis cluster"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}

### --------------------------------------------------
### Replication Group
### --------------------------------------------------
resource "aws_elasticache_replication_group" "main" {
  replication_group_id = local.identifier
  description          = "Redis replication group for ${local.identifier}"

  engine         = "redis"
  engine_version = var.engine_version
  node_type      = var.node_type
  port           = var.port

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = distinct(concat([aws_security_group.main.id], var.additional_security_group_ids))

  parameter_group_name = length(aws_elasticache_parameter_group.main) > 0 ? aws_elasticache_parameter_group.main[0].name : null

  num_cache_clusters         = var.number_cache_clusters
  multi_az_enabled           = var.multi_az_enabled
  automatic_failover_enabled = var.automatic_failover_enabled

  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  auth_token                 = local.auth_token

  apply_immediately        = var.apply_immediately
  maintenance_window       = local.maintenance_window
  snapshot_window          = local.snapshot_window
  snapshot_retention_limit = var.snapshot_retention_limit

  tags = local.tags
}

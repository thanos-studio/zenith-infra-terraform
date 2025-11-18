locals {
  load_balancer_name = substr(lower(join("-", compact([var.project_name, var.environment, var.name]))), 0, 32)
  tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Sigmoid"
    },
    var.tags,
    {
      Name = local.load_balancer_name
    }
  )

  target_groups             = { for tg in var.target_groups : tg.name => tg }
  default_target_group_name = lookup(local.target_groups, var.default_target_group_name, null) != null ? var.default_target_group_name : element(keys(local.target_groups), 0)

  listener_ports = distinct(concat(
    var.enable_http_listener ? [80] : [],
    var.enable_https_listener ? [443] : []
  ))
}

### --------------------------------------------------
### Security Group
### --------------------------------------------------
resource "aws_security_group" "alb" {
  name        = "${local.load_balancer_name}-sg"
  description = "Security group for the ${local.load_balancer_name} ALB"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.listener_ports
    content {
      description = "Listener port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.allowed_ingress_cidrs
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${local.load_balancer_name}-sg" })
}

### --------------------------------------------------
### Load Balancer & Target Groups
### --------------------------------------------------
resource "aws_lb" "main" {
  name               = local.load_balancer_name
  load_balancer_type = "application"
  internal           = var.internal
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = local.tags
}

resource "aws_lb_target_group" "main" {
  for_each = local.target_groups

  name        = substr("${local.load_balancer_name}-${each.key}", 0, 32)
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = var.vpc_id
  target_type = each.value.target_type

  health_check {
    interval            = each.value.health_check_interval
    path                = each.value.health_check_path
    protocol            = each.value.protocol
    timeout             = each.value.health_check_timeout
    healthy_threshold   = each.value.healthy_threshold
    unhealthy_threshold = each.value.unhealthy_threshold
    matcher             = each.value.health_check_matcher
  }

  tags = merge(local.tags, { TargetGroup = each.key })
}

### --------------------------------------------------
### Listeners
### --------------------------------------------------
resource "aws_lb_listener" "http" {
  count             = var.enable_http_listener ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[local.default_target_group_name].arn
  }
}

resource "aws_lb_listener" "https" {
  count             = var.enable_https_listener ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.https_certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[local.default_target_group_name].arn
  }
}

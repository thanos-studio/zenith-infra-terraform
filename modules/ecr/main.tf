locals {
  repositories = { for name in var.repositories : name => "${var.namespace}/${name}" }

  tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Sigmoid"
    },
    var.tags
  )
}

resource "aws_ecr_repository" "this" {
  for_each = local.repositories

  name                 = each.value
  image_tag_mutability = "MUTABLE"
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(local.tags, {
    Name        = each.value
    Repository  = each.key
    Namespace   = var.namespace
    Environment = var.environment
  })
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = aws_ecr_repository.this

  repository = each.value.name
  policy = templatefile("${path.module}/policies/lifecycle-policy.json", {
    count_number = var.lifecycle_policy_keep_count
  })
}

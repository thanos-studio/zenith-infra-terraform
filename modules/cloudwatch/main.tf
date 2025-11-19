locals {
  name_prefix             = "${var.project_name}-${var.environment}"
  eks_dashboard_name      = "${local.name_prefix}-eks-operations"
  database_dashboard_name = "${local.name_prefix}-database-health"
  edge_dashboard_name     = "${local.name_prefix}-edge-observability"
  service_dashboard_name  = "${local.name_prefix}-service-load"

  eks_dashboard_body = templatefile("${path.module}/dashboards/eks.json.tpl", {
    region              = var.region
    eks_cluster_name    = var.eks_cluster_name
    eks_node_group_name = var.eks_node_group_name
  })

  database_dashboard_body = templatefile("${path.module}/dashboards/database.json.tpl", {
    region                           = var.region
    rds_instance_identifier          = var.rds_instance_identifier
    elasticache_replication_group_id = var.elasticache_replication_group_id
  })

  edge_dashboard_body = templatefile("${path.module}/dashboards/edge.json.tpl", {
    region                      = var.region
    cloudfront_region           = var.cloudfront_region
    load_balancers              = var.load_balancers
    cloudfront_distribution_ids = var.cloudfront_distribution_ids
  })

  service_dashboard_body = templatefile("${path.module}/dashboards/service_load.json.tpl", {
    region                = var.region
    service_target_groups = var.service_target_groups
    eks_cluster_name      = var.eks_cluster_name
  })
}

resource "aws_cloudwatch_dashboard" "eks" {
  dashboard_name = local.eks_dashboard_name
  dashboard_body = local.eks_dashboard_body
}

resource "aws_cloudwatch_dashboard" "database" {
  dashboard_name = local.database_dashboard_name
  dashboard_body = local.database_dashboard_body
}

resource "aws_cloudwatch_dashboard" "edge" {
  dashboard_name = local.edge_dashboard_name
  dashboard_body = local.edge_dashboard_body
}

resource "aws_cloudwatch_dashboard" "service" {
  dashboard_name = local.service_dashboard_name
  dashboard_body = local.service_dashboard_body
}

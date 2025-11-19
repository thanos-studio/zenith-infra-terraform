output "dashboard_names" {
  description = "CloudWatch dashboard names created by the module."
  value = {
    eks      = aws_cloudwatch_dashboard.eks.dashboard_name
    database = aws_cloudwatch_dashboard.database.dashboard_name
    edge     = aws_cloudwatch_dashboard.edge.dashboard_name
    service  = aws_cloudwatch_dashboard.service.dashboard_name
  }
}

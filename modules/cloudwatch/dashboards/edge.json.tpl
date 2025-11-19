{
  "widgets": [
    {
      "type": "metric",
      "width": 12,
      "height": 6,
      "x": 0,
      "y": 0,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "region": "${region}",
        "stat": "Sum",
        "period": 300,
        "title": "ALB Request Count",
        "metrics": [
%{ for idx, lb in load_balancers }
          ${jsonencode(["AWS/ApplicationELB", "RequestCount", "LoadBalancer", lb.arn_suffix, { "label": lb.name, "stat": "Sum" }])}%{ if idx < length(load_balancers) - 1 },%{ endif }
%{ endfor }
        ]
      }
    },
    {
      "type": "metric",
      "width": 12,
      "height": 6,
      "x": 12,
      "y": 0,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "region": "${region}",
        "stat": "Average",
        "period": 300,
        "title": "ALB Target Response Time (avg)",
        "metrics": [
%{ for idx, lb in load_balancers }
          ${jsonencode(["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", lb.arn_suffix, { "label": format("%s avg", lb.name), "stat": "Average" }])}%{ if idx < length(load_balancers) - 1 },%{ endif }
%{ endfor }
        ]
      }
    },
    {
      "type": "metric",
      "width": 12,
      "height": 6,
      "x": 0,
      "y": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "region": "${region}",
        "period": 300,
        "title": "ALB Target Response Time Percentiles",
        "metrics": [
%{ for idx, lb in load_balancers }
          ${jsonencode(["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", lb.arn_suffix, { "label": format("%s p99", lb.name), "stat": "p99" }])},
          ${jsonencode(["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", lb.arn_suffix, { "label": format("%s p95", lb.name), "stat": "p95" }])},
          ${jsonencode(["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", lb.arn_suffix, { "label": format("%s p90", lb.name), "stat": "p90" }])}%{ if idx < length(load_balancers) - 1 },%{ endif }
%{ endfor }
        ]
      }
    },
    {
      "type": "metric",
      "width": 12,
      "height": 6,
      "x": 12,
      "y": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "region": "${region}",
        "stat": "Sum",
        "period": 300,
        "title": "ALB HTTP Errors",
        "metrics": [
%{ for idx, lb in load_balancers }
          ${jsonencode(["AWS/ApplicationELB", "HTTPCode_ELB_4XX_Count", "LoadBalancer", lb.arn_suffix, { "label": format("%s 4XX", lb.name), "stat": "Sum" }])},
          ${jsonencode(["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", lb.arn_suffix, { "label": format("%s 5XX", lb.name), "stat": "Sum" }])},
          ${jsonencode(["AWS/ApplicationELB", "RejectedConnectionCount", "LoadBalancer", lb.arn_suffix, { "label": format("%s Rejected", lb.name), "stat": "Sum" }])}%{ if idx < length(load_balancers) - 1 },%{ endif }
%{ endfor }
        ]
      }
    },
    {
      "type": "metric",
      "width": 12,
      "height": 6,
      "x": 0,
      "y": 12,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "region": "${cloudfront_region}",
        "stat": "Sum",
        "period": 300,
        "title": "CloudFront Requests & Traffic",
        "metrics": [
%{ for idx, dist in cloudfront_distribution_ids }
          ${jsonencode(["AWS/CloudFront", "Requests", "DistributionId", dist, "Region", "Global", { "label": format("%s Requests", dist), "stat": "Sum" }])},
          ${jsonencode(["AWS/CloudFront", "BytesDownloaded", "DistributionId", dist, "Region", "Global", { "label": format("%s Bytes", dist), "stat": "Sum" }])}%{ if idx < length(cloudfront_distribution_ids) - 1 },%{ endif }
%{ endfor }
        ]
      }
    },
    {
      "type": "metric",
      "width": 12,
      "height": 6,
      "x": 12,
      "y": 12,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "region": "${cloudfront_region}",
        "period": 300,
        "title": "CloudFront TotalLatency Percentiles",
        "metrics": [
%{ for idx, dist in cloudfront_distribution_ids }
          ${jsonencode(["AWS/CloudFront", "TotalLatency", "DistributionId", dist, "Region", "Global", { "label": format("%s p99", dist), "stat": "p99" }])},
          ${jsonencode(["AWS/CloudFront", "TotalLatency", "DistributionId", dist, "Region", "Global", { "label": format("%s p95", dist), "stat": "p95" }])},
          ${jsonencode(["AWS/CloudFront", "TotalLatency", "DistributionId", dist, "Region", "Global", { "label": format("%s p90", dist), "stat": "p90" }])}%{ if idx < length(cloudfront_distribution_ids) - 1 },%{ endif }
%{ endfor }
        ]
      }
    }
  ]
}

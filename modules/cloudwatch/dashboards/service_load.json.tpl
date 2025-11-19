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
        "title": "Service RequestCountPerTarget",
        "metrics": [
%{ for idx, svc in service_target_groups }
          ${jsonencode(["AWS/ApplicationELB", "RequestCountPerTarget", "TargetGroup", svc.target_group_arn_suffix, { "label": svc.name, "stat": "Sum" }])}%{ if idx < length(service_target_groups) - 1 },%{ endif }
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
        "stat": "Sum",
        "period": 300,
        "title": "Service Target Errors",
        "metrics": [
%{ for idx, svc in service_target_groups }
          ${jsonencode(["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "TargetGroup", svc.target_group_arn_suffix, "LoadBalancer", svc.load_balancer_arn_suffix, { "label": format("%s 4XX", svc.name), "stat": "Sum" }])},
          ${jsonencode(["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "TargetGroup", svc.target_group_arn_suffix, "LoadBalancer", svc.load_balancer_arn_suffix, { "label": format("%s 5XX", svc.name), "stat": "Sum" }])}%{ if idx < length(service_target_groups) - 1 },%{ endif }
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
        "stat": "Average",
        "period": 300,
        "title": "Service Healthy Targets",
        "metrics": [
%{ for idx, svc in service_target_groups }
          ${jsonencode(["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", svc.target_group_arn_suffix, { "label": format("%s healthy", svc.name), "stat": "Average" }])}%{ if idx < length(service_target_groups) - 1 },%{ endif }
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
        "period": 300,
        "title": "Pod CPU Utilization Percentiles",
        "metrics": [
          [
            "ContainerInsights",
            "pod_cpu_utilization",
            "ClusterName",
            "${eks_cluster_name}",
            { "label": "p99", "stat": "p99" }
          ],
          [
            ".",
            "pod_cpu_utilization",
            ".",
            ".",
            { "label": "p95", "stat": "p95" }
          ],
          [
            ".",
            "pod_cpu_utilization",
            ".",
            ".",
            { "label": "p90", "stat": "p90" }
          ]
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
        "region": "${region}",
        "period": 300,
        "title": "Pod Availability",
        "metrics": [
          [
            "ContainerInsights",
            "pod_number_of_running_containers",
            "ClusterName",
            "${eks_cluster_name}",
            { "label": "Running Containers", "stat": "Average" }
          ],
          [
            ".",
            "pod_number_of_pending_pods",
            ".",
            ".",
            { "label": "Pending Pods", "stat": "Average" }
          ],
          [
            ".",
            "pod_number_of_container_restarts",
            ".",
            ".",
            { "label": "Container Restarts", "stat": "Sum" }
          ]
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
        "region": "${region}",
        "period": 300,
        "title": "Pod Memory Utilization Percentiles",
        "metrics": [
          [
            "ContainerInsights",
            "pod_memory_utilization",
            "ClusterName",
            "${eks_cluster_name}",
            { "label": "p99", "stat": "p99" }
          ],
          [
            ".",
            "pod_memory_utilization",
            ".",
            ".",
            { "label": "p95", "stat": "p95" }
          ],
          [
            ".",
            "pod_memory_utilization",
            ".",
            ".",
            { "label": "p90", "stat": "p90" }
          ]
        ]
      }
    }
  ]
}

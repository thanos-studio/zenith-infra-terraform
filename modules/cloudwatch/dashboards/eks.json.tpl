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
        "stat": "Average",
        "period": 300,
        "title": "Node Group Capacity (${eks_node_group_name})",
        "metrics": [
          [
            "AWS/EKS",
            "NodeGroupDesiredCapacity",
            "ClusterName",
            "${eks_cluster_name}",
            "NodeGroupName",
            "${eks_node_group_name}",
            { "label": "Desired", "stat": "Average" }
          ],
          [
            ".",
            "NodeGroupActiveNodes",
            ".",
            ".",
            ".",
            ".",
            { "label": "Active", "stat": "Average" }
          ],
          [
            ".",
            "NodeGroupPendingNodes",
            ".",
            ".",
            ".",
            ".",
            { "label": "Pending", "stat": "Average" }
          ]
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
        "title": "Cluster Health",
        "metrics": [
          [
            "AWS/EKS",
            "ClusterFailedNodeCount",
            "ClusterName",
            "${eks_cluster_name}",
            { "label": "Failed Nodes", "stat": "Average" }
          ],
          [
            "ContainerInsights",
            "pod_number_of_pending_pods",
            "ClusterName",
            "${eks_cluster_name}",
            { "label": "Pending Pods", "stat": "Average" }
          ]
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
        "title": "Node CPU Utilization",
        "metrics": [
          [
            "ContainerInsights",
            "node_cpu_utilization",
            "ClusterName",
            "${eks_cluster_name}",
            { "label": "CPU %", "stat": "Average" }
          ]
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
        "stat": "Average",
        "period": 300,
        "title": "Node Memory Utilization",
        "metrics": [
          [
            "ContainerInsights",
            "node_memory_utilization",
            "ClusterName",
            "${eks_cluster_name}",
            { "label": "Memory %", "stat": "Average" }
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
        "stat": "Average",
        "period": 300,
        "title": "Pod CPU Utilization",
        "metrics": [
          [
            "ContainerInsights",
            "pod_cpu_utilization",
            "ClusterName",
            "${eks_cluster_name}",
            { "label": "CPU %", "stat": "Average" }
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
        "stat": "Average",
        "period": 300,
        "title": "Pod Memory Utilization",
        "metrics": [
          [
            "ContainerInsights",
            "pod_memory_utilization",
            "ClusterName",
            "${eks_cluster_name}",
            { "label": "Memory %", "stat": "Average" }
          ]
        ]
      }
    },
    {
      "type": "metric",
      "width": 12,
      "height": 6,
      "x": 0,
      "y": 18,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "region": "${region}",
        "stat": "Average",
        "period": 300,
        "title": "Pod Network I/O",
        "metrics": [
          [
            "ContainerInsights",
            "pod_network_rx_bytes",
            "ClusterName",
            "${eks_cluster_name}",
            { "label": "RX Bytes", "stat": "Sum" }
          ],
          [
            ".",
            "pod_network_tx_bytes",
            ".",
            ".",
            { "label": "TX Bytes", "stat": "Sum" }
          ]
        ]
      }
    },
    {
      "type": "metric",
      "width": 12,
      "height": 6,
      "x": 12,
      "y": 18,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "region": "${region}",
        "stat": "Sum",
        "period": 300,
        "title": "Pod Restarts & Running Containers",
        "metrics": [
          [
            "ContainerInsights",
            "pod_number_of_container_restarts",
            "ClusterName",
            "${eks_cluster_name}",
            { "label": "Container Restarts", "stat": "Sum" }
          ],
          [
            ".",
            "pod_number_of_running_containers",
            ".",
            ".",
            { "label": "Running Containers", "stat": "Average" }
          ]
        ]
      }
    }
  ]
}

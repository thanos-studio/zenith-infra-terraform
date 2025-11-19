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
        "period": 300,
        "title": "RDS CPU & Memory",
        "metrics": [
          [
            "AWS/RDS",
            "CPUUtilization",
            "DBInstanceIdentifier",
            "${rds_instance_identifier}",
            { "label": "CPU %", "stat": "Average" }
          ],
          [
            ".",
            "FreeableMemory",
            ".",
            ".",
            { "label": "Freeable Memory", "stat": "Average" }
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
        "period": 300,
        "title": "RDS Storage & IOPS",
        "metrics": [
          [
            "AWS/RDS",
            "FreeStorageSpace",
            "DBInstanceIdentifier",
            "${rds_instance_identifier}",
            { "label": "Free Storage", "stat": "Average" }
          ],
          [
            ".",
            "ReadIOPS",
            ".",
            ".",
            { "label": "Read IOPS", "stat": "Average" }
          ],
          [
            ".",
            "WriteIOPS",
            ".",
            ".",
            { "label": "Write IOPS", "stat": "Average" }
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
        "period": 300,
        "title": "RDS Throughput & Connections",
        "metrics": [
          [
            "AWS/RDS",
            "DatabaseConnections",
            "DBInstanceIdentifier",
            "${rds_instance_identifier}",
            { "label": "Connections", "stat": "Average" }
          ],
          [
            ".",
            "ReadThroughput",
            ".",
            ".",
            { "label": "Read Throughput", "stat": "Average" }
          ],
          [
            ".",
            "WriteThroughput",
            ".",
            ".",
            { "label": "Write Throughput", "stat": "Average" }
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
        "period": 300,
        "title": "RDS Latency & Replica Lag",
        "metrics": [
          [
            "AWS/RDS",
            "ReadLatency",
            "DBInstanceIdentifier",
            "${rds_instance_identifier}",
            { "label": "Read Latency", "stat": "Average" }
          ],
          [
            ".",
            "WriteLatency",
            ".",
            ".",
            { "label": "Write Latency", "stat": "Average" }
          ],
          [
            ".",
            "ReplicaLag",
            ".",
            ".",
            { "label": "Replica Lag", "stat": "Average" }
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
        "title": "ElastiCache CPU & Memory",
        "metrics": [
          [
            "AWS/ElastiCache",
            "CPUUtilization",
            "ReplicationGroupId",
            "${elasticache_replication_group_id}",
            { "label": "CPU %", "stat": "Average" }
          ],
          [
            ".",
            "FreeableMemory",
            ".",
            ".",
            { "label": "Freeable Memory", "stat": "Average" }
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
        "title": "ElastiCache Connections & Swap",
        "metrics": [
          [
            "AWS/ElastiCache",
            "CurrConnections",
            "ReplicationGroupId",
            "${elasticache_replication_group_id}",
            { "label": "Connections", "stat": "Average" }
          ],
          [
            ".",
            "SwapUsage",
            ".",
            ".",
            { "label": "Swap Usage", "stat": "Average" }
          ],
          [
            ".",
            "Evictions",
            ".",
            ".",
            { "label": "Evictions", "stat": "Sum" }
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
        "period": 300,
        "title": "ElastiCache Network",
        "metrics": [
          [
            "AWS/ElastiCache",
            "NetworkBytesIn",
            "ReplicationGroupId",
            "${elasticache_replication_group_id}",
            { "label": "Bytes In", "stat": "Sum" }
          ],
          [
            ".",
            "NetworkBytesOut",
            ".",
            ".",
            { "label": "Bytes Out", "stat": "Sum" }
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
        "period": 300,
        "title": "ElastiCache Cache Efficiency",
        "metrics": [
          [
            "AWS/ElastiCache",
            "CacheHits",
            "ReplicationGroupId",
            "${elasticache_replication_group_id}",
            { "label": "Cache Hits", "stat": "Sum" }
          ],
          [
            ".",
            "CacheMisses",
            ".",
            ".",
            { "label": "Cache Misses", "stat": "Sum" }
          ]
        ]
      }
    }
  ]
}

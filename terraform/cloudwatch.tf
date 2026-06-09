resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "ec2_dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 24
        height = 8

        properties = {
          metrics = [
            [{
              # 1. Hypervisor Domain: Default EC2 CPU telemetry
              expression = "SEARCH('{AWS/EC2, AutoScalingGroupName} AutoScalingGroupName=\"${aws_autoscaling_group.dev_asg.name}\" CPUUtilization', 'Average', 60)"
              id         = "dynamic_cpu_lines"
              label      = "[CPU: $${LABEL}]"
            }],
            [{
              # 2. Operating System Domain: Memory agent tracking
              expression = "SEARCH('{CWAgent, AutoScalingGroupName, InstanceId} AutoScalingGroupName=\"${aws_autoscaling_group.dev_asg.name}\"  MetricName=\"mem_used_percent\"', 'Average', 60)"
              id         = "dynamic_mem_lines"
              label      = "$${PROP('Dim.InstanceId')}"
              #label      = "[RAM: $${LABEL}]"
            }],
            [{
              # 3. Storage Subsystem Domain: Targeted physical disk parsing
              expression = "SEARCH('{CWAgent, AutoScalingGroupName, InstanceId, path, device, fstype} AutoScalingGroupName=\"${aws_autoscaling_group.dev_asg.name}\" path=\"/\" device=\"nvme0n1p1\" fstype=\"ext4\" disk_used_percent', 'Average', 60)"
              id         = "dynamic_disk_lines"
              label      = "$${PROP('Dim.InstanceId')}"
              #label      = "[Disk: $${LABEL}]"
            }]

            # [{
            #   expression = "SEARCH('{CWAgent, AutoScalingGroupName, InstanceId} AutoScalingGroupName=\"${aws_autoscaling_group.dev_asg.name}\" MetricName=\"mem_used_percent\"', 'Average', 60)"
            #   id         = "dynamic_mem_lines"
            #   label      = "$${PROP('Dim.InstanceId')}"
            # }]

          ],
          "period"  = 60
          "stat"    = "Average"
          "region"  = "eu-west-2"
          "title"   = "EC2 Instance Metrics Utilization"
          "view"    = "timeSeries"
          "stacked" = false
        }
      },
      {
        type   = "text"
        x      = 0
        y      = 7
        width  = 3
        height = 3

        properties = {
          markdown = "EC2"
        }
      }
    ]
  })
}
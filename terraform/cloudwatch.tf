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
          metrics = concat(
            [for vm in aws_instance.app_server : [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              "${vm.id}"
              ]
            ],

            [for vm in aws_instance.app_server : [
              "CWAgent",
              "mem_used_percent",
              "InstanceId",
              "${vm.id}",
              "ImageId",
              "${vm.ami}",
              "InstanceType",
              "${vm.instance_type}"
              ]

            ],
            [for vm in aws_instance.app_server : [
              "CWAgent",
              "disk_used_percent",
              "InstanceId",
              "${vm.id}",
              "ImageId",
              "${vm.ami}",
              "InstanceType",
              "${vm.instance_type}",
              "path", "/",
              "device", "nvme0n1p1",
              "fstype", "ext4"
              ]
            ]

          )
          "period" = 60
          "stat"   = "Average"
          "region" = "eu-west-2"
          "title"  = "EC2 Instance CPU Utilization"
          "view" : "timeSeries",
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
resource "aws_placement_group" "dev" {
  name     = "dev"
  strategy = "spread"
}

resource "aws_launch_template" "dev-launch" {
  name_prefix            = "dev_lt"
  image_id               = var.aws_ami_image
  instance_type          = var.aws_instance_type
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2-iam.name
  }
}

resource "aws_autoscaling_group" "dev_asg" {
  desired_capacity          = 2
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier       = [aws_subnet.dev.id]
  placement_group           = aws_placement_group.dev.id
  depends_on                = [aws_vpc_endpoint.interface]

  launch_template {
    id      = aws_launch_template.dev-launch.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "dev_pol" {
  name                   = "auto-scale_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.dev_asg.name
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_util" {
  alarm_name          = "ec2 metrics alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 85

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.dev_asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.dev_pol.arn]
}

resource "aws_cloudwatch_metric_alarm" "ec2_mem_used" {
  alarm_name          = "ec2 metrics alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 120
  statistic           = "Average"
  threshold           = 85

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.dev_asg.name
  }

  alarm_description = "This metric monitors ec2 mem utilization"
  alarm_actions     = [aws_autoscaling_policy.dev_pol.arn]
}

resource "aws_cloudwatch_metric_alarm" "ec2_disk_used" {
  alarm_name          = "ec2 metrics alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = 120
  statistic           = "Average"
  threshold           = 85

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.dev_asg.name
  }

  alarm_description = "This metric monitors ec2 disk utilization"
  alarm_actions     = [aws_autoscaling_policy.dev_pol.arn]
}
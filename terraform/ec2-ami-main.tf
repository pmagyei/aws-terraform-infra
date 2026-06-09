# resource "aws_instance" "app_server" {
#   count                       = 2
#   ami                         = var.aws_ami_image
#   instance_type               = var.aws_instance_type
#   iam_instance_profile        = aws_iam_instance_profile.ec2-iam.name
#   vpc_security_group_ids      = [aws_security_group.ec2-sg.id]
#   user_data_replace_on_change = true
# #  subnet_id                   = aws_subnet.dev.id
#   tags = {
#     Name = "SRV-${count.index}"
#   }


#   user_data = <<-EOF
# #!/bin/bash

# mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/

# wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
# dpkg -i amazon-cloudwatch-agent.deb
# apt update
# apt install stress-ng -y


# cat << 'AGENT_CONFIG' > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
# {
#   "agent": {
#     "metrics_collection_interval": 60,
#     "run_as_user": "cwagent",
#     "region": "eu-west-2",
#     "usage_metadata": [
#       {
#         "ObservabilitySolution": "ec2_health"
#       },
#       {
#         "ObservabilitySolution": "log_collection"
#       }
#     ]
#   },
#   "metrics": {
#     "namespace": "CWAgent",
#     "aggregation_dimensions": [
#       [
#         "AutoScalingGroupName"
#       ]
#     ],
#     "metrics_collected": {
#       "mem": {
#         "measurement": [
#           "mem_used_percent"
#         ]
#       },
#       "disk": {
#         "measurement": [
#           "disk_used_percent"
#         ],
#         "resources": [
#           "/"
#         ]
#       }
#     },
#     "append_dimensions": {
#       "AutoScalingGroupName": "$${aws:AutoScalingGroupName}",
#       "InstanceId": "$${aws:InstanceId}"
#     },
#     "logs": {
#       "logs_collected": {
#         "files": {
#           "collect_list": [
#             {
#               "file_path": "/var/log/syslog",
#               "log_group_name": "UbuntuSyslog",
#               "log_stream_name": "{instance_id}"
#             }
#           ]
#         }
#       }
#     }
#   }
# }
# AGENT_CONFIG

# /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
#   -a fetch-config \
#   -m ec2 \
#   -s \
#   -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json


# EOF
# }


# resource "aws_security_group" "ec2-sg" {
# #  vpc_id = aws_vpc.aws-dev.id
#   ingress {
#     from_port        = 443
#     to_port          = 443
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]

#     description = "HTTPS from IPv4 + IPv6"
#   }

#   egress {
#     # from_port   = 443
#     # to_port     = 443
#     # protocol    = "tcp"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#   #  cidr_blocks = ["172.27.10.0/27"]
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allows only CIDR block IPs"
#   }
# }






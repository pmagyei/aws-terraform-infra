resource "aws_instance" "name" {
  ami                    = var.aws_ami_image
  instance_type          = var.aws_instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2-iam.name
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]


  user_data = <<EOF
    #!/bin/bash
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
    sudo dpkg -i amazon-cloudwatch-agent.deb
    
    cat << 'AGENT_CONFIG' > /opt/aws/amazon-cloudwatch-agent/etc/config.json 
    { "agent": { "metrics_collection_interval": 60, "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log" },
  "metrics": {
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_used_percent",
          "mem_available",
          "mem_total",
          "mem_used"
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          "disk_used_percent",
          "disk_free",
          "disk_total",
          "disk_inodes_free"
        ],
        "resources": ["/", "/data"],
        "metrics_collection_interval": 60,
        "ignore_file_system_types": [
          "sysfs", "devtmpfs", "tmpfs", "overlay"
        ]
      },
      "diskio": {
        "measurement": [
          "diskio_io_time",
          "diskio_read_bytes",
          "diskio_write_bytes",
          "diskio_reads",
          "diskio_writes"
        ],
        "resources": ["*"],
        "metrics_collection_interval": 60
      },
      "swap": {
        "measurement": ["swap_used_percent"],
        "metrics_collection_interval": 60
      },
      "net": {
        "measurement": [
          "net_bytes_recv",
          "net_bytes_sent",
          "net_packets_recv",
          "net_packets_sent",
          "net_err_in",
          "net_err_out"
        ],
        "resources": ["eth0"],
        "metrics_collection_interval": 60
      },
      "processes": {
        "measurement": [
          "processes_running",
          "processes_sleeping",
          "processes_zombies",
          "processes_total"
        ],
        "metrics_collection_interval": 60
      },
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_user",
          "cpu_usage_system",
          "cpu_usage_iowait",
          "cpu_usage_steal"
        ],
        "totalcpu": true,
        "metrics_collection_interval": 60
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          { "file_path": "/var/log/syslog", "log_group_name": "UbuntuSyslog" }
        ]
      }
    }
  }
AGENT_CONFIG}

systemctl enable amazon-cloudwatch-agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json

EOF
}
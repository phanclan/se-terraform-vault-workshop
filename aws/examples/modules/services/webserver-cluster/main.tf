# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE ALL THE RESOURCES TO DEPLOY AN APP IN AN AUTO SCALING GROUP WITH AN ELB
# This template runs a simple "Hello, World" web server in Auto Scaling Group (ASG) with an Elastic
# Load Balancer (ELB) in front of it to distribute traffic across the EC2 Instances in the ASG.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# -------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# -------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.12"
}

# -------------------------------------------------------------------------------------------------
# GET LIST OF AZ'S IN CURRENT REGION
# -------------------------------------------------------------------------------------------------

data "aws_availability_zones" "all" {}

# -------------------------------------------------------------------------------------------------
# CREATE LAUNCH CONFIGURATION FOR EC2 IN ASG
# -------------------------------------------------------------------------------------------------

resource "aws_launch_configuration" "example" {
  image_id        = "ami-0c55b159cbfafe1f0" # ubuntu 18.04 LTS us-e2
  instance_type   = "t3.small" # micro:2x1, small: 2x2
  security_groups = [aws_security_group.instance.id]  
  
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World" `hostname` > index.html
    nohup busybox httpd -f -p "${var.server_port}" &
    EOF  
  lifecycle {
    create_before_destroy = true
  }
}

# -------------------------------------------------------------------------------------------------
# CREATE AUTO SCALING GROUP
# -------------------------------------------------------------------------------------------------

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.id  
  availability_zones = data.aws_availability_zones.all.names

  min_size = 2
  max_size = 10  

  load_balancers = [aws_elb.example.name]
  health_check_type = "ELB"
  
  tag {
    key                 = "Name"
    value               = "phan-${var.cluster_name}-asg"
    propagate_at_launch = true
  }
}


# -------------------------------------------------------------------------------------------------
# CREATE ELB FOR ASG
# -------------------------------------------------------------------------------------------------
resource "aws_elb" "example" {
  name               = "phan-${var.cluster_name}-asg"
  security_groups    = [aws_security_group.elb.id]
  availability_zones = data.aws_availability_zones.all.names

  # HTTP health check; send HTTP every 30 for /
  health_check {
    target              = "HTTP:${var.server_port}/"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  # This adds a listener for incoming HTTP requests.
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
}

# -------------------------------------------------------------------------------------------------
# CREATE SECURITY GROUP FOR EC2 IN ASG
# -------------------------------------------------------------------------------------------------

resource "aws_security_group" "instance" {
  name = "phan-${var.cluster_name}-instance"  
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------------------------------------------------------------------------------
# CREATE SECURITY GROUP FOR ELB
# -------------------------------------------------------------------------------------------------

resource "aws_security_group" "elb" {
  name = "phan-${var.cluster_name}-elb"  

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  
  }
  
  # Inbound HTTP from anywhere
  ingress {
    from_port   = var.elb_port
    to_port     = var.elb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# -------------------------------------------------------------------------------------------------
variable "server_port" {
  description = "Server port for HTTP Request"
  default = "8080"
}
variable "elb_port" {
  description = "Server port for HTTP Request"
  default = "80"
}
variable "cluster_name" {
  description = "The name for all cluster resources"
}

# output "public_ip" {
#   value = aws_instance.example.public_ip
#   description = "Public IP of web server"
# }

output "clb_dns_name" {
  value = aws_elb.example.dns_name
  description = "The fqdn of the load balancer"
}
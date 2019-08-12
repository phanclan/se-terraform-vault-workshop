provider "aws" {
  region = "us-east-2"
}
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0" # ubuntu 18.04
  instance_type = "t3.small" # micro:2x1, small: 2x2
  vpc_security_group_ids = [ aws_security_group.instance.id ] # This points to sg.

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World" > index.html
    nohup busybox httpd -f -p "${var.server_port}" &
    EOF
  tags = {
    Name = "phan-terraform-example"
  }
}

resource "aws_security_group" "instance" {
  name = "phan-terraform-example-instance"  
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "server_port" {
  default = "8080"
}

output "public_ip" {
  value = aws_instance.example.public_ip
  description = "Public IP of web server"
}
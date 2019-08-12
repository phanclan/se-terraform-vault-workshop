provider "aws" {
  region = "us-east-2"
}
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0" # ubuntu 18.04
  instance_type = "t3.micro"
  vpc_security_group_ids = [ aws_security_group.instance.id ] # This points to sg.

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World" > index.html
    nohup busybox httpd -f -p 8080 &
    EOF
  tags = {
    Name = "phan-terraform-example"
  }
}

resource "aws_security_group" "instance" {
  name = "phan-terraform-example-instance"  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
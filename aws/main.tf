##############################################################################
# HashiCorp Terraform and Vault Workshop
#
# This Terraform configuration will create the following:
#
# AWS VPC with a subnet
# A Linux server running HashiCorp Vault and a simple application
# A hosted RDS MySQL database server

/* This is the provider block. We recommend pinning the provider version to
a known working version. If you leave this out you'll get the latest
version. */

terraform { 
  required_version = ">= 0.12.0"
  # backend "remote" {
  #   organization = "phanpeterhc1"
  #   workspaces {
  #     name = "test"
  #   }
  # }
}



# resource "aws_vpc" "workshop" {
#   cidr_block       = "${var.address_space}.0.0/16"
#   tags = {
#     Name = "${var.prefix}-workshop"
#     environment = "Production"
#   }
# }

# module "uw2" {
#   source = "./modules/uw2"
#   prefix = "${var.prefix}"
#   env = "${var.env}"
#   uw2-pub-net = "${var.uw2-pub-net}"
#   uw2-pri-net = "${var.uw2-pri-net}"
#   owner = "${var.owner}"
#   address_space = "${var.address_space}"
#   subnet_prefix = "${var.subnet_prefix}"
#   key_name = "${var.prefix}-tf_ec2_key"
# }

# resource "aws_subnet" "subnet" {
#   vpc_id     = "${aws_vpc.workshop.id}"
#   availability_zone = "${var.region}a"
#   cidr_block = "${var.subnet_prefix}"

#   tags = {
#     Name = "${var.prefix}-workshop-subnet"
#   }
#   tags = {
#     Name = "tf-${var.prefix}-${var.env}workshop"
#     TTL = "72"
#     owner = "team-se@hashicorp.com"
#   }
# }

# resource "aws_subnet" "subnet2" {
#   vpc_id     = "${aws_vpc.workshop.id}"
#   availability_zone = "${var.region}b"
#   cidr_block = "${var.address_space}.11.0/24"

#   tags = {
#     Name = "${var.prefix}-workshop-subnet"
#   }
# }

# resource "aws_internet_gateway" "main-gw" {
#     vpc_id = "${aws_vpc.workshop.id}"

# }

# resource "aws_route_table" "main-public" {
#     vpc_id = "${aws_vpc.workshop.id}"
#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id = "${aws_internet_gateway.main-gw.id}"
#     }
# }

# resource "aws_route_table_association" "main-public-1-a" {
#     subnet_id = "${aws_subnet.subnet.id}"
#     route_table_id = "${aws_route_table.main-public.id}"
# }

# resource "aws_security_group" "vault-sg" {
#   name        = "${var.prefix}-sg"
#   description = "Vault Security Group"
#   vpc_id      = "${aws_vpc.workshop.id}"

#   ingress {
#     from_port   = 8200
#     to_port     = 8200
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 5000
#     to_port     = 5000
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     cidr_blocks     = ["0.0.0.0/0"]
#   }
# }

# resource "aws_security_group" "mysql-workshop-sg" {
#   name        = "${var.prefix}-mysql-sg"
#   description = "Mysql Security Group"
#   vpc_id      = "${aws_vpc.workshop.id}"

#   ingress {
#     from_port   = 3306
#     to_port     = 3306
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.0.0/8"]
#   }

#   egress {
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     cidr_blocks     = ["0.0.0.0/0"]
#   }
# }


# resource "aws_db_subnet_group" "default" {
#   name       = "${var.prefix}-subnet-group"
#   subnet_ids = ["${aws_subnet.subnet.id}", "${aws_subnet.subnet2.id}"]

#   tags = {
#     Name = "tf-workshop-subnet"
#   }
# }

# resource "aws_db_instance" "vault-demo" {
#   allocated_storage    = 20
#   identifier           = "${var.prefix}-tf-workshop-rds"
#   db_subnet_group_name = "${aws_db_subnet_group.default.id}"
#   storage_type         = "gp2"
#   engine               = "mysql"
#   engine_version       = "5.7"
#   instance_class       = "db.t2.micro"
#   final_snapshot_identifier = "foo"
#   skip_final_snapshot  = true
#   name                 = "wsmysqldatabase"
#   username             = "hashicorp"
#   password             = "Password123!"
#   parameter_group_name = "default.mysql5.7"
#   vpc_security_group_ids = ["${aws_security_group.mysql-workshop-sg.id}"]
# }

# output "uw2_vault_pub_ip" {
#   value = "${module.uw2.vault_pub_ip}"
# }

# output "uw2_pub_net_cidr" {
#   value = "${module.uw2.uw2_pub_net_cidr}"
# }


# output "uw2_pub_net_cidr" {
#   value = "${aws_subnet.pri_net.cidr_block}"
# }
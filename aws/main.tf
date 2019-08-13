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
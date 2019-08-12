# gcp/main.tf
#--------------------------------------------------------------------------------------------------
# HashiCorp Terraform and Vault Workshop
#
# This Terraform configuration will create the following:
#
# GCP VPC with a subnet
# A Linux server running HashiCorp Vault and a simple application
# A hosted RDS MySQL database server

#--------------------------------------------------------------------------------------------------
# Configure the Google Cloud provider
#--------------------------------------------------------------------------------------------------

provider "google" {
  credentials = "${file("~/.gcp/CRED_FILE.json")}"
  project     = var.gcp-project
  #version = = "2.10" # Pin the version or you get the latest
  # region  = var.region
}

#--------------------------------------------------------------------------------------------------
#----- VPC
#--------------------------------------------------------------------------------------------------
module "vpc" {
  source = "./modules/global"
  env    = "${var.env}"
  prefix = "${var.prefix}"
}

#--------------------------------------------------------------------------------------------------
#----- network.tf -----
module "uw1" {
  source            = "./modules/uw1"
  network_self_link = "${module.vpc.out_vpc_self_link}"
  # subnetwork1 = "${module.uw1.uw1_out_public_subnet_name}"
  prefix      = "${var.prefix}"
  env         = "${var.env}"
  uw1-pub-net = "${var.uw1-pub-net}"
  uw1-pri-net = "${var.uw1-pri-net}"
  owner       = "${var.owner}"
  vault_count = "1"
}

# module "ue1" {
#   source            = "./modules/ue1"
#   network_self_link = "${module.vpc.out_vpc_self_link}"
#   env         = "${var.env}"
#   ue1-pub-net = "${var.ue1-pub-net}"
#   ue1-pri-net = "${var.ue1-pri-net}"
#   prefix      = "${var.prefix}"
#   owner       = "${var.owner}"
# }

#--------------------------------------------------------------------------------------------------
# Display Output Public Instance
#--------------------------------------------------------------------------------------------------

output "uw1_public_address" {
  value = "${module.uw1.pub_address}"
}

# output "ue1_public_address" {
#   value = "pephan@${module.ue1.ue1_pub_addres}"
# }

output "sn_uw1_pub_net_name" {
  value = "${module.uw1.sn_uw1_pub_net_name}"
}

output "sn_uw1_pri_net_name" {
  value = "${module.uw1.sn_uw1_pri_net_name}"
}

output "sn_uw1_pub_net_cidr" {
  value = "${module.uw1.sn_uw1_pub_net_cidr}"
}

output "sn_uw1_pri_net_cidr" {
  value = "${module.uw1.sn_uw1_pri_net_cidr}"
}

output "gn_vpc_name" {
  value = "${module.vpc.vpc_name}"
}

# output "gn_vpc_self_link" {
#   value = "${module.vpc.out_vpc_self_link}"
# }


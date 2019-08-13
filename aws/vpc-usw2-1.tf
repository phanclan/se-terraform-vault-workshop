##############################################################################
# HashiCorp Terraform and Vault Workshop
#
# This Terraform configuration will create the following:
#
# 1. AWS VPC, two public subnets, two private subnets
# 2. Bastion host, linux host
# 3. A Linux server running HashiCorp Vault and a simple application

locals {
  name_prefix = "${var.prefix}-${var.env}-${var.region}"
  common_tags = {
    Owner       = var.owner
    Environment = var.env
    Name        = "${var.prefix}-${var.env}-usw2-1"
    TTL         = "72"
  }
}

resource "aws_key_pair" "tf_usw2_ec2_key" {
  key_name   = "tf-${var.prefix}-${var.env}-usw2-ec2-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjOXiqjoBMlfCBvmG6BcUGPv1q+YqNYLHlm6X18Frue+Yf2zG/56pMWtSoPbHKB+Nul0VNpANuOyt3qsEU+HtZz9MMTBiWL6kGH6S0saLMp7EpcZaib/Qxfkl1By6JnOwr6w7eW+XE4TXHRdBKaRWW4J52KdhlPXAeMFeSDL3qnZWaP7tIyKTQzdDXu0rSJIBpcYCVCQ5BkshWNvoVpDH0dH9r4ayLrzgnNzQHyqVFASU3DxqIAqrC3JflAz1aUWiwXhDJeZU3w6eDWvYxOAm+Z2vP5oiX/pqbYMlCUlPrsU5+6828kDQ5uQaZiCnSi2Bj3BDqpJngiVvyicJgvhW9 pephan@Mac-mini.local"
  # public_key = "${file("~/.ssh/id_rsa.pub")}"
  # public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhhEKJBWpUOHomxK6+8IJ7awT27/HfwG80PK+SrwAFaM4WhTg526etf5ksDpyjRQd3j1XDX9jVYUT5vTIaQ/YhqNVyaLM2ayY6GhAR+R+PIdpK1bhvfMvp6Rgsbii8PsD1HnKEJTOJayrhVY7W95mTUIGmCAWiIN1qrR04ffpfxNJdYcZdLbXu6DnT/EKJS9hQRgWLjQYSmJ0sOy4LeW7NqbDoOEunfzv8bX2dGbE4zn+ZpFSOAUC/VQTyxdkRPGiv3ocJyz+qbbSf7qCxYW61UX3K6Zdn/0ND8vqpl9xMvejPSk/4mIMNGuSrO8i/SzbgcM5ulS09KIw7GMoD6rwF peterphan@Peters-MacBook-Pro.local"
}

# module "ssh_keypair_aws" {
#   source = "github.com/hashicorp-modules/ssh-keypair-aws"
#   name = "tf-pphan-ssh-keypair-aws"
# }

#------------------------------------------------------------------------------
# Use vpc module to create VPC, subnets, IGW, NGW, RT
#------------------------------------------------------------------------------
module "vpc_usw2-1" {
  source         = "terraform-aws-modules/vpc/aws"
  name           = "tf-${var.prefix}-${var.env}-uw1-vpc"
  cidr           = "${var.cidr}"
  azs            = ["us-west-2a", "us-west-2b"]
  public_subnets = "${var.public_subnets}"
  private_subnets     = "${var.private_subnets}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  # enable_nat_gateway = true
  # single_nat_gateway = true
  tags                     = local.common_tags
  igw_tags                 = { Name = "tf-${var.prefix}-${var.env}-usw2-1-IGW" }
  nat_gateway_tags         = { Name = "tf-${var.prefix}-${var.env}-usw2-1-NGW" }
  public_route_table_tags  = { Name = "tf-${var.prefix}-${var.env}-usw2-1-RT-public" }
  public_subnet_tags       = { Name = "tf-${var.prefix}-${var.env}-usw2-1-public" }
  private_route_table_tags = { Name = "tf-${var.prefix}-${var.env}-usw2-1-RT-private" }
  private_subnet_tags      = { Name = "tf-${var.prefix}-${var.env}-usw2-1-private" }
}

resource "aws_security_group" "usw2-1_bastion_sg" {
  name        = "tf-${var.prefix}-${var.env}-bastion-sg"
  description = "Vault Security Group"
  vpc_id      = module.vpc_usw2-1.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
}
resource "aws_security_group" "egress_public_sg" {
  name        = "tf-${var.prefix}-${var.env}-egress-public-sg"
  description = "Allow outbound"
  vpc_id      = module.vpc_usw2-1.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
}

resource "aws_security_group" "vpc_usw2-1_ping_ssh_sg" {
  name        = "tf_${var.prefix}_${var.env}-ping-ssh-sg"
  description = "Internal Security Group"
  vpc_id      = "${module.vpc_usw2-1.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "user_data" {
  template = "${file("../templates/user_data.tpl")}"
  vars = {
    prefix = "${var.prefix}"
  }
}

data "template_file" "install_base" {
  template = "${file("../templates/install-base.sh.tpl")}"
  vars = {
    prefix = "${var.prefix}"
  }
}
data "template_file" "install_docker" {
  template = "${file("../templates/install-docker.sh.tpl")}"
}
# data "template_file" "install_vault" {
#   template = "${file("../templates/install-hashi.sh.tpl")}"
#   vars = {
#     vault_version        = "${var.vault_version}"
#     vault_zip            = "vault_${var.vault_version}_linux_amd64.zip"
#     vault_url            = "https://releases.hashicorp.com/vault/${var.vault_version}/vault_${var.vault_version}_linux_amd64.zip"
#     vault_dir            = "/usr/local/bin"
#     vault_path           = "/usr/local/bin/vault"
#     vault_config_dir     = "/etc/vault.d"
#     vault_data_dir       = "/opt/vault/data"
#     vault_tls_dir        = "/opt/vault/tls"
#     vault_env_vars       = "/etc/vault.d/vault.conf"
#     vault_profile_script = "/etc/profile.d/vault.sh"
#     name                 = "${var.name}"
#     local_ip_url         = "${var.local_ip_url}"
#     vault_override       = "${var.vault_config_override != "" ? true : false}"
#     vault_config         = "${var.vault_config_override}"
#   }
# }

data "template_file" "install_hashi" {
  template = "${file("${path.root}/../templates/install-hashi.sh.tpl")}"
  vars = {
    TF_VERSION     = var.TF_VERSION
    VAULT_VERSION  = var.VAULT_VERSION
    CONSUL_VERSION = var.CONSUL_VERSION
  }
}

#------------------------------------------------------------------------------
# VM INSTANCES
#------------------------------------------------------------------------------
module "usw2-1_bastion" {
  source = "terraform-aws-modules/ec2-instance/aws"
  instance_count = var.bastion_count
  name = "phan" # name_prefix
  ami = data.aws_ami.ubuntu.id
  instance_type = var.vm_size
  key_name = aws_key_pair.tf_usw2_ec2_key.key_name
  subnet_id = module.vpc_usw2-1.public_subnets[0]
  vpc_security_group_ids = ["${aws_security_group.usw2-1_bastion_sg.id}",
    "${aws_security_group.egress_public_sg.id}",
    "${module.vpc_usw2-1.default_security_group_id}",
  ]
  associate_public_ip_address = true
  private_ip = "10.10.1.10"
  user_data = <<EOF
${data.template_file.install_base.rendered} # Runtime install base tools
${data.template_file.install_docker.rendered} # Install Docker
${data.template_file.install_hashi.rendered} # Install Hashi Suite
EOF
  tags = local.common_tags
}

module "usw2-1_pri_ubuntu" {
  source = "terraform-aws-modules/ec2-instance/aws"
  instance_count = var.internal_vm_count
  name = "phant" # name_prefix
  ami   = data.aws_ami.ubuntu.id
  instance_type = var.vm_size
  subnet_id     = module.vpc_usw2-1.private_subnets[0]
  vpc_security_group_ids = [
    "${aws_security_group.vpc_usw2-1_ping_ssh_sg.id}",
    "${module.vpc_usw2-1.default_security_group_id}",
    "${module.usw2-1_elb.elb-sg-id}"
  ]
  key_name = aws_key_pair.tf_usw2_ec2_key.key_name
  # count.index does not work with module
  # private_ip = "10.10.11.1${count.index}"
  private_ip = "10.10.11.10"
  #private_ips = ["10.10.11.10","10.10.11.11"] # need to match instance_count
  user_data  = <<EOF
${data.template_file.install_base.rendered} # Runtime install base tools
${data.template_file.install_docker.rendered} # Install Docker
${data.template_file.install_hashi.rendered} # Runtime install Vault in -dev mode
EOF
  tags = local.common_tags
}

# module "usw2-1_elb" {
#   source      = "./modules/elb"
#   name_prefix = local.name_prefix
#   vpc_id      = module.vpc_usw2-1.vpc_id
#   subnets     = module.vpc_usw2-1.public_subnets
#   instances   = module.usw2-1_pri_ubuntu.*.id
#   common_tags        = local.common_tags
# }
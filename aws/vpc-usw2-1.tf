##############################################################################
# HashiCorp Terraform and Vault Workshop
#
# This Terraform configuration will create the following:
#
# 1. AWS VPC, two public subnets, two private subnets
# 2. Bastion host, linux host
# 3. A Linux server running HashiCorp Vault and a simple application

locals {
  common_tags = {
    Owner       = "Peter Phan"
    Environment = "${var.env}"
    Name        = "tf-${var.prefix}-${var.env}-usw2-1"
    TTL = "72"
  }
}
resource "aws_key_pair" "tf_usw2_ec2_key" {
  key_name = "tf-${var.prefix}-${var.env}-usw2-ec2-key"
#  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjOXiqjoBMlfCBvmG6BcUGPv1q+YqNYLHlm6X18Frue+Yf2zG/56pMWtSoPbHKB+Nul0VNpANuOyt3qsEU+HtZz9MMTBiWL6kGH6S0saLMp7EpcZaib/Qxfkl1By6JnOwr6w7eW+XE4TXHRdBKaRWW4J52KdhlPXAeMFeSDL3qnZWaP7tIyKTQzdDXu0rSJIBpcYCVCQ5BkshWNvoVpDH0dH9r4ayLrzgnNzQHyqVFASU3DxqIAqrC3JflAz1aUWiwXhDJeZU3w6eDWvYxOAm+Z2vP5oiX/pqbYMlCUlPrsU5+6828kDQ5uQaZiCnSi2Bj3BDqpJngiVvyicJgvhW9 pephan@Mac-mini.local"
#  public_key = "${file("~/.ssh/id_rsa.pub")}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhhEKJBWpUOHomxK6+8IJ7awT27/HfwG80PK+SrwAFaM4WhTg526etf5ksDpyjRQd3j1XDX9jVYUT5vTIaQ/YhqNVyaLM2ayY6GhAR+R+PIdpK1bhvfMvp6Rgsbii8PsD1HnKEJTOJayrhVY7W95mTUIGmCAWiIN1qrR04ffpfxNJdYcZdLbXu6DnT/EKJS9hQRgWLjQYSmJ0sOy4LeW7NqbDoOEunfzv8bX2dGbE4zn+ZpFSOAUC/VQTyxdkRPGiv3ocJyz+qbbSf7qCxYW61UX3K6Zdn/0ND8vqpl9xMvejPSk/4mIMNGuSrO8i/SzbgcM5ulS09KIw7GMoD6rwF peterphan@Peters-MacBook-Pro.local"
}

# module "ssh_keypair_aws" {
#   source = "github.com/hashicorp-modules/ssh-keypair-aws"
#   name = "tf-pphan-ssh-keypair-aws"
# }

# Use vpc module to create VPC, subnets, IGW, NGW, RT
module "vpc_usw2-1" {
  source = "terraform-aws-modules/vpc/aws"
  name = "tf-${var.prefix}-${var.env}-uw1-vpc"
  cidr = "${var.cidr}"
  azs = ["us-west-2a","us-west-2b"]
  public_subnets = "${var.public_subnets}"
  private_subnets     = "${var.private_subnets}"
  enable_dns_hostnames = true
  enable_dns_support = true
  # enable_nat_gateway = true
  # single_nat_gateway = true
  tags = local.common_tags
  igw_tags = { Name = "tf-${var.prefix}-${var.env}-usw2-1-IGW" }
  nat_gateway_tags = { Name = "tf-${var.prefix}-${var.env}-usw2-1-NGW"}
  public_route_table_tags = { Name = "tf-${var.prefix}-${var.env}-usw2-1-RT-public" }
  public_subnet_tags = { Name = "ctf-${var.prefix}-${var.env}-usw2-1-public" }
  private_route_table_tags = { Name = "tf-${var.prefix}-${var.env}-usw2-1-RT-private" }
  private_subnet_tags = { Name = "tf-${var.prefix}-${var.env}-usw2-1-private" }
}

resource "aws_security_group" "vpc_usw2-1_bastion_sg" {
  name        = "tf-${var.prefix}-${var.env}-bastion-sg"
  description = "Vault Security Group"
  vpc_id      = "${module.vpc_usw2-1.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "tf-${var.prefix}-${var.env}-workshop"
    TTL = "72"
    owner = "team-se@hashicorp.com"
  }
}

resource "aws_security_group" "vpc_usw2-1_ping_ssh_sg" {
  name        = "tf_${var.prefix}_${var.env}_ping_ssh_sg"
  # description = "Internal Security Group"
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
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = local.common_tags
}

data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"] # Canonical
}

data "template_file" "user_data" {
  template = "${file("modules/templates/user_data.tpl")}"
  vars = {
    prefix = "${var.prefix}"
  }
}

data "template_file" "base_install" {
  template = "${file("modules/templates/install-base.sh.tpl")}"
}
data "template_file" "install_docker" {
  template = "${file("modules/templates/install-docker.sh.tpl")}"
}

data "template_file" "vault_install" {
  template = "${file("modules/templates/install-vault-systemd.sh.tpl")}"

  vars = {
    vault_version  = "${var.hashistack_vault_version}"
    vault_url      = "${var.hashistack_vault_url}"
    name           = "${var.name}"
    local_ip_url   = "${var.local_ip_url}"
    vault_override = "${var.vault_config_override != "" ? true : false}"
    vault_config   = "${var.vault_config_override}"
  }
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "user_data.tpl"
    content_type = "text/cloud-config"
    content      = "${data.template_file.user_data.rendered}"
  }
  # Docker cloud-config configuration file.
  part {
    filename     = "install-docker.sh.tpl"
    content_type = "text/cloud-config"
    content      = "${data.template_file.install_docker.rendered}"
  }
}

resource "aws_instance" "vpc_usw2-1_bastion" {
  count = "${var.bastion_count}"
  ami           = "${data.aws_ami.ubuntu.id}"
  #ami                         = "${var.ubuntu_ami}"
  instance_type               = "${var.vm_size}"
  associate_public_ip_address = true
  subnet_id                   = "${module.vpc_usw2-1.public_subnets[0]}"
  vpc_security_group_ids     = ["${aws_security_group.vpc_usw2-1_bastion_sg.id}", "${module.vpc_usw2-1.default_security_group_id}"]
  key_name                    = "${aws_key_pair.tf_usw2_ec2_key.key_name}"
  # user_data                   = "${data.template_file.user_data.rendered}"
  user_data_base64 = "${data.template_cloudinit_config.config.rendered}"
  private_ip                  = "10.10.1.10"

  tags = local.common_tags
}

resource "aws_instance" "vpc_usw2-1_pri_ubuntu" {
  count = "${var.internal_vm_count}"
  ami           = "${data.aws_ami.ubuntu.id}"
  #ami                         = "${var.ubuntu_ami}"
  instance_type               = "${var.vm_size}"
  subnet_id                   = "${module.vpc_usw2-1.private_subnets[0]}"
  vpc_security_group_ids     = [
    "${aws_security_group.vpc_usw2-1_ping_ssh_sg.id}", 
    "${module.vpc_usw2-1.default_security_group_id}",
    "${aws_security_group.elb-sg.id}"
  ]
  key_name                    = "${aws_key_pair.tf_usw2_ec2_key.key_name}"
  private_ip                  = "10.10.11.1${count.index}"
  user_data = <<EOF
"${data.template_file.user_data.rendered}"
${data.template_file.base_install.rendered} # Runtime install base tools
${data.template_file.vault_install.rendered} # Runtime install Vault in -dev mode
EOF
  # user_data                   = "${data.template_file.user_data.rendered}"
  # connection {
  #   user = "ubuntu"
  #   host = "${self.public_ip}"
  #   private_key = "${file("~/.ssh/id_rsa")}"
  # }
  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo apt-get -y update",
  #     "sudo apt -y install nginx",
  #     "sudo service nginx start",
  #   ]
  # }
  tags = local.common_tags
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb-sg" {
  name        = "tf-${var.prefix}-${var.env}-sg"
  description = "Used in the terraform"
  vpc_id      = "${module.vpc_usw2-1.vpc_id}"
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
}

# resource "aws_elb" "web" {
#   name = "tf-${var.prefix}-${var.env}-example-elb"

#   # The same availability zone as our instances
#   subnets = "${module.vpc_usw2-1.public_subnets}"
#   security_groups = [ "${aws_security_group.elb-sg.id}" ]

#   listener {
#     instance_port     = 80
#     instance_protocol = "http"
#     lb_port           = 80
#     lb_protocol       = "http"
#   }

#   # The instances are registered automatically
#   instances = "${aws_instance.vpc_usw2-1_pri_ubuntu.*.id}"
# }


##############################################################################
# Variables File
#
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)

#------------------------------------------------
#----- General Variables 
#------------------------------------------------
variable "bastion_count" { default = "0" }
variable "internal_vm_count" { default = "0" }

variable "region" {
  description = "The amazon region to use."
  default     = "us-west-2"
}
variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "t3.small"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.1"
}

# variable "subnet_prefix" {
#   description = "The address prefix to use for the subnet."
#   default     = "10.1.10.0/24"
# }


variable "prefix" {
  description = "This prefix will be included in the name of most resources."
  default = "pphan"
}
variable "env" {
  default = "dev"
}

variable "owner" {
  default = "pphan"
}


#------------------------------------------------
#----- Network Variables 
#------------------------------------------------
variable "cidr" { default = "10.10.0.0/16" }
variable "public_subnets" {
  default = ["10.10.1.0/24", "10.10.2.0/24"]
}
variable "private_subnets" {
  default = ["10.10.11.0/24", "10.10.12.0/24"]
}

# the following four variables were before modules
# variable "uw2-pub-net" { default = "10.1.10.0/24" }
# variable "uw2-pri-net" { default = "10.1.100.0/24" }
# variable "ue1-pub-net" { default = "10.1.20.0/24" }
# variable "ue1-pri-net" { default = "10.1.200.0/24" }

# variable "key_name" {
#   description = "key to use with instance"
# }

#------------------------------------------------
#----- HashiStack Variables 
#------------------------------------------------
variable "name" { default = "hashistack-dev" }
variable "local_ip_url" { default = "http://169.254.169.254/latest/meta-data/local-ipv4" }

variable "hashistack_servers" { default = 1 }
variable "hashistack_instance" { default = "t3.micro" }
variable "VAULT_VERSION" { default = "1.1.3" }
variable "TF_VERSION" { default = "0.12.6" }
variable "CONSUL_VERSION" { default = "1.5.3" }
variable "hashistack_consul_version" { default = "1.2.3" }
variable "vault_version" { default = "1.2.0" }
variable "hashistack_nomad_version" { default = "0.8.6" }
variable "hashistack_consul_url" { default = "" }
variable "vault_url" { default = "" }
# variable "vault_zip" { default = ""}
variable "hashistack_nomad_url" { default = "" }
variable "hashistack_image_id" { default = "" }

variable "hashistack_public" {
  description = "Assign a public IP, open port 22 for public access, & provision into public subnets to provide easier accessibility without a Bastion host - DO NOT DO THIS IN PROD"
  default     = true
}

variable "consul_config_override" { default = "" }
variable "vault_config_override" { default = "" }
variable "nomad_config_override" { default = "" }
variable "nomad_docker_install" { default = true }
variable "nomad_java_install" { default = true }

variable "hashistack_tags" {
  type    = "map"
  default = {}
}

variable "hashistack_tags_list" {
  type    = "list"
  default = []
}


#------------------------------------------------
# Vault
#------------------------------------------------



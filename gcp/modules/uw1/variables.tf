# gcp/variables.tf
##############################################################################
# Variables File
#
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)

variable "prefix" {
  description = "This prefix will be included in the name of most resources."
}
variable "owner" {}
variable "region" {
  description = "The gcp region to use."
  default     = "us-west1"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.1"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.1.10.0/24"
}

variable "uw1-pub-net" {}

variable "uw1-pri-net" {}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "g1-small"
}
variable "vault_count" {}

variable "env" {
  default = "dev"
}

# variable "subnetwork1" {}

variable "network_self_link" {}
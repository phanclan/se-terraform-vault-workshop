##############################################################################
# Variables File
#
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)

variable "prefix" {
  description = "This prefix will be included in the name of most resources."
}

variable "region" {
  description = "The amazon region to use."
  default     = "us-west-2"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.1"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.1.10.0/24"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "t3.small"
}

variable "env" {
  default = "dev"
}

variable "owner" {
  default = "pphan"
}

variable "uw2-pub-net" {
  default = "10.1.10.0/24"
}

variable "uw2-pri-net" {
  default = "10.1.100.0/24"
}

variable "ue1-pub-net" {
  default = "10.1.20.0/24"
}

variable "ue1-pri-net" {
  default = "10.1.200.0/24"
}

# variable "key_name" {
#   description = "key to use with instance"
# }

###################################
#----- HashiStack Variables -----
###################################

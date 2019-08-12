# gcp/variables.tf
##############################################################################
# Variables File
#
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)

variable "prefix" {
  description = "Prefix included in the name of most resources."
}

variable "company" { default = "company-name" }

variable "gcp-project" { default = "project-name" }

# Moved to regional modules
# variable "region" {}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.1"
}

variable "uw1-pub-net" {
  default = "10.1.10.0/24"
}

variable "uw1-pri-net" {
  default = "10.1.100.0/24"
}

variable "ue1-pub-net" {
  default = "10.1.20.0/24"
}

variable "ue1-pri-net" {
  default = "10.1.200.0/24"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "g1-small"
}

variable "env" {
  default = "dev"
}

variable "owner" {
  default = "pphan"
}
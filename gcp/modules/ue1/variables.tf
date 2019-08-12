# gcp/variables.tf
##############################################################################
# Variables File
#
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)

variable "prefix" {}
variable "owner" {}
variable "region" {
  description = "The gcp region to use."
  default     = "us-east1"
}

variable "ue1-pub-net" {}
variable "ue1-pri-net" {}
variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "g1-small"
}
variable "env" {}
# variable "subnetwork1" {}
variable "network_self_link" {}
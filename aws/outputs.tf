##############################################################################
# Outputs File
#
# Expose the outputs you want your users to see after a successful
# `terraform apply` or `terraform output` command. You can add your own text
# and include any data from the state file. Outputs are sorted alphabetically;
# use an underscore _ to move things to the bottom. In this example we're
# providing instructions to the user on how to connect to their own custom
# demo environment.
#
# output "Vault_Server_URL" {
#   value = "http://${aws_instance.vault-server.public_ip}:8200"
# }
# output "MySQL_Server_FQDN" {
#   value = "${aws_db_instance.vault-demo.address}"
# }
# output "Instructions" {
#   value = <<EOF
# ################################################################################
# # Connect to your Linux Virtual Machine
# #
# # Run the command below to SSH into your server. You can also use PuTTY or any
# # other SSH client. Your SSH key is already loaded for you.
# ################################################################################

# ssh ubuntu@${aws_instance.vault-server.public_ip}
# EOF
# }


# output "vpc_usw2-1_bastion_pub_ip" {
#   value = "${aws_instance.vpc_usw2-1_bastion.public_ip}"
# }
# output "vpc_usw2-1_bastion_pub_fqdn" {
#   value = "${aws_instance.vpc_usw2-1_bastion.public_dns}"
# }

# output "vpc_usw2-1_pri_ubuntu0" {
#   value = "Instances: ${element(aws_instance.vpc_usw2-1_pri_ubuntu.*.id,0)}"
# }
# Using the new splat operator (*)
output "vpc_usw2-1_pri_ubuntu" {
  value = "${aws_instance.vpc_usw2-1_pri_ubuntu[*].private_ip}"
}
# New conditional expression with lists ()
output "vpc_usw2-1_pri_ubuntu_new_cond" {
  value = [
    for instance in aws_instance.vpc_usw2-1_pri_ubuntu:
    (instance.public_ip != "" ? list(instance.private_ip, instance.public_ip) : list(instance.private_ip))
  ]
}
# New conditional expression with lists []
output "vpc_usw2-1_pri_ubuntu_new_cond_brackets" {
  value = [
    for instance in aws_instance.vpc_usw2-1_pri_ubuntu:
    (instance.public_ip != "" ? [instance.private_ip, instance.public_ip] : [instance.private_ip])
  ]
}
# output "uw2_pub_net_cidr" {
#   value = "${module.uw2.uw2_pub_net_cidr}"
# }

# output "uw2_pub_net_cidr" {
#   value = "${aws_subnet.pri_net.cidr_block}"
# }
variable "names" {
  default = "joe,jimmy,billy"
}

resource "local_file" "kubeconfig" {
  content  = "${data.template_file.install_vault.rendered}"
  filename = "install_vault_output_pp.txt"
}
data "template_file" "init" {
  # count = "${length(split(",", var.names))}"
  template = "${file("modules/templates/test.tpl")}"
  vars = {
    test = "${var.names}"
  }
}
 
# resource "null_resource" "web" {
#   count = "${length(split(",", var.names))}"
#   triggers = {
#     template_rendered = "${join(",", data.template_file.init.*.rendered)}"
#   }
 
#   provisioner "local-exec" {
#     command = "echo \"${join(",", data.template_file.init.*.rendered)}\" >> out.txt"
#   }
#   # provisioner "local-exec" {
#   #   command = "echo \"${data.template_file.init.*.rendered}\" >> out2.txt"
#   # }
# }
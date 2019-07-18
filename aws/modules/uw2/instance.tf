# aws/modules/uw2/instance.tf

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}



# module "ssh-keypair-aws" {
#   source = "github.com/scarolan/ssh-keypair-aws"
#   name   = "${var.prefix}-workshop"
# }

resource "aws_instance" "vault-server" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.vm_size}"
  subnet_id     = "${aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.vault-sg.id}"]
  associate_public_ip_address = "true"
  # key_name = "${module.ssh-keypair-aws.name}"
  key_name = "${var.key_name}"
  tags = {
    Name = "${var.prefix}-tf-workshop"
    TTL = "72"
    owner = "team-se@hashicorp.com"
  }
  connection {
    type = "ssh"
    user = "ubuntu"
    #private_key = "${module.ssh-keypair-aws.private_key_pem}"
    private_key = "${file("~/.ssh/id_rsa")}"
    host = "${aws_instance.vault-server.public_ip}"
  }

  provisioner "file" {
    source      = "files/"
    destination = "/home/ubuntu/"
  }

  # Put a copy of the ssh key onto the local workstation
  # provisioner "local-exec" {
  #   interpreter = ["PowerShell", "-Command"]
  #   command = <<-EOF
  #             New-Item -ItemType Directory -Force -Path $${env:HOMEPATH}\.ssh
  #             Write-Output @"
  #             ${module.ssh-keypair-aws.private_key_pem}
  #             "@ | Out-File $${env:HOMEPATH}\.ssh\id_rsa
  #             ((Get-Content $${env:HOMEPATH}\.ssh\id_rsa) -join "`n") + "`n" | Set-Content -NoNewline $${env:HOMEPATH}\.ssh\id_rsa
  #             EOF
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #   "chmod -R +x /home/ubuntu/",
  #   "sleep 30",
  #   "MYSQL_ENDPOINT=${aws_db_instance.vault-demo.endpoint} MYSQL_HOST=${aws_db_instance.vault-demo.address} MYSQL_PORT=${aws_db_instance.vault-demo.port} /home/ubuntu/setup.sh"
  #   ]
  # }
}

output "vault_pub_ip" {
  value = "${aws_instance.vault-server.public_ip}"
}
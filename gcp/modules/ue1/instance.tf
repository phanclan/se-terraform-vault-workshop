# gcp/ue1/instance.tf
###########################################################
#----- Instances -----

resource "random_id" "instance_id" {
  byte_length = 4
}

resource "google_compute_instance" "vault-server" {
  name         = "tf-${var.prefix}-vault-dev-vm-${random_id.instance_id.hex}"
  machine_type = "${var.vm_size}"
  # GCP does not have us-east1-a zone.
  zone         = "${var.region}-b"
  # vpc_security_group_ids = ["${aws_security_group.vault-sg.id}"]
  # associate_public_ip_address = "true"
  # key_name = "${module.ssh-keypair-aws.name}"

  scheduling {
    preemptible       = "true"
    automatic_restart = "false"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
      type  = "pd-ssd"
    }
  }

  network_interface {
    #network = "default"
    subnetwork = "${google_compute_subnetwork.public-net.name}"
    # This next line is needed to get public IP.
    access_config {}
  }

  metadata_startup_script = <<EOF
  sudo apt update; sudo apt install -y apache2 stress
  EOF

  metadata = {
    ssh-keys = "pephan:${file("~/.ssh/id_rsa.pub")}"
  }
  tags = ["ssh", "http"]

  labels = {
    ttl = "24"
    owner = "${var.owner}"
  }

  # tags = {
  #   Name = "${var.prefix}-tf-workshop"
  #   TTL = "72"
  #   owner = "team-se@hashicorp.com"
  # }
  # connection {
  #   type = "ssh"
  #   user = "ubuntu"
  #   private_key = "${module.ssh-keypair-aws.private_key_pem}"
  #   host = "${aws_instance.vault-server.public_ip}"
  # }

  # provisioner "file" {
  #   source      = "files/"
  #   destination = "/home/ubuntu/"
  # }

  # # Put a copy of the ssh key onto the local workstation
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

output "ue1_pub_addres" {
  value = "${google_compute_instance.vault-server.network_interface.0.access_config.0.nat_ip}"
}

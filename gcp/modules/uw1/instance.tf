# gcp/uw1/instance.tf
#--------------------------------------------------------------------------------------------------
#----- Instances -----
#--------------------------------------------------------------------------------------------------

data "template_file" "init" {
  template = "${file("${path.root}/../templates/install-base.sh.tpl")}"
  vars = { 
    prefix = "phan"
  }
}

#--------------------------------------------------------------------------------------------------
#----- RANDOM ID FOR INSTANCE
#--------------------------------------------------------------------------------------------------

resource "random_id" "instance_id" {
  byte_length = 4
}

resource "google_compute_instance" "vault-server" {
  count = var.vault_count
  name         = "tf-${var.prefix}-vault-dev-vm-${random_id.instance_id.hex}"
  machine_type = var.vm_size
  zone         = "${var.region}-a"

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
    subnetwork = google_compute_subnetwork.public-net.name
    access_config {} # needed to get public IP.
    network_ip    = "10.1.10.10" #"${var.ip_db}"
  }

  metadata_startup_script = data.template_file.init.rendered

  metadata = {
    ssh-keys = "ubuntu:${var.public_key}"
  #   startup_script = <<EOF
  #   apt-get -y update
  #   apt-get -y install apach2 wget curl
  #   EOF
  }

  tags = ["ssh", "http"] # Some FW rules assigned by network tags

  // labels is equivalent to AWS tags. lower case only
  labels = {
    ttl = "24"
    owner = var.owner
    name = "${var.prefix}-workshop"
  }

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

#----- Create a new DBSERVER instance
resource "google_compute_instance" "dbserver" {
  count = "0"
  name         = "tf-${var.prefix}-${var.env}-db-vm-${random_id.instance_id.hex}"
  machine_type = "${var.vm_size}"
  zone         = "${var.region}-a"
  #can_ip_forward            = true
  #allow_stopping_for_update = true
  #count                     = 1

  // Adding METADATA Key Value pairs to DB-SERVER 
  metadata = {
    # startup-script-url = "${var.db_startup_script_bucket}"
    # serial-port-enable = true
    ssh-keys = "pphan:${var.public_key}"
    # sshKeys                              = "${var.public_key}"
  }

  # service_account {
  #   scopes = "${var.scopes_db}"
  # }

  network_interface {
    subnetwork = "${google_compute_subnetwork.private-net.name}"
    network_ip    = "10.1.100.10" #"${var.ip_db}"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
      type  = "pd-ssd"
      # image = "${var.image_db}"
    }
  }

  // labels is equivalent to AWS tags. lower case only
  labels = {
    ttl = "24"
    owner = var.owner
    name = "${var.prefix}-workshop"
  }
}

#--------------------------------------------------------------------------------------------------
# Display Output Public Instance
#--------------------------------------------------------------------------------------------------

output "pub_address" {
  value = "${google_compute_instance.vault-server[*].network_interface.0.access_config.0.nat_ip}"
}

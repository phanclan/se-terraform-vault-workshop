# global/vpc.tf
###########################################################
#----- VPC.tf -----
# CIDR is defined under network.tf in subnetwork resource
###########################################################

resource "google_compute_network" "vpc" {
  name                    = "tf-${var.prefix}-${var.env}-vpc"
  auto_create_subnetworks = "false"
  #routing_mode            = "GLOBAL"
}

# resource "aws_vpc" "workshop" {
#   cidr_block       = "${var.address_space}.0.0/16"
#   tags = {
#     Name = "${var.prefix}-workshop"
#     environment = "Production"
#   }
# }

###########################################################
#----- Firewall Rules -----
###########################################################

resource "google_compute_firewall" "fw-internal" {
  name = "tf-${var.prefix}-fw-internal"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports = ["80","8080","22"]
  }
  # Need to lock down source ranges!!!
  source_ranges = [
    "0.0.0.0/0"
  ]
}

resource "google_compute_firewall" "fw-external" {
  name = "tf-${var.prefix}-fw-external"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports = ["80","8080"]
  }
  # Need to lock down source ranges!!!
  source_ranges = [
    "0.0.0.0/0"
  ]
}


resource "google_compute_firewall" "fw-bastion" {
  name = "tf-${var.prefix}-fw-bastion"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  # source_ranges = [
  #   "0.0.0.0/0"
  # ]
  target_tags = ["ssh"]
}

resource "google_compute_firewall" "vault-fw" {
  name = "tf-${var.prefix}-fw-vault"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports = ["8200","5000"]
  }
  # source_ranges = [
  #   "0.0.0.0/0"
  # ]
  target_tags = ["vault"]
}

resource "google_compute_firewall" "mysql-fw" {
  name = "tf-${var.prefix}-fw-mysql"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports = ["3306"]
  }
  # source_ranges = [
  #   "0.0.0.0/0"
  # ]
  target_tags = ["mysql"]
}

output "out_vpc_self_link" {
  value = "${google_compute_network.vpc.self_link}"
}

output "vpc_name" {
  value = "${google_compute_network.vpc.name}"
}
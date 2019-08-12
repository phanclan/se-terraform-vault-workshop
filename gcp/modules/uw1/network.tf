# uw1/variables.tf
###########################################################
#----- Subnetworks -----
###########################################################
resource "google_compute_subnetwork" "public-net" {
  name          = "${var.prefix}-${var.env}-${var.region}-pub-net"
  ip_cidr_range = "${var.uw1-pub-net}"
  network       = "${var.network_self_link}"
  region        = "${var.region}"
}

resource "google_compute_subnetwork" "private-net" {
  name          = "${var.prefix}-${var.env}-${var.region}-pri-net"
  ip_cidr_range = "${var.uw1-pri-net}"
  network       = "${var.network_self_link}"
  region        = "${var.region}"
}

output "sn_uw1_pub_net_name" {
  value = "${google_compute_subnetwork.public-net.name}"
}

output "sn_uw1_pri_net_name" {
  value = "${google_compute_subnetwork.private-net.name}"
}

output "sn_uw1_pub_net_cidr" {
  value = "${google_compute_subnetwork.public-net.ip_cidr_range}"
}

output "sn_uw1_pri_net_cidr" {
  value = "${google_compute_subnetwork.private-net.ip_cidr_range}"
}
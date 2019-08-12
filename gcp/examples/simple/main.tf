#--------------------------------------------------------------------------------------------------
# Configure the Google Cloud provider
#--------------------------------------------------------------------------------------------------
provider "google" {
  credentials = "${file("~/.gcp/CRED_FILE.json")}" # JSON file from service account
  project     = "pphan-test-app-dev" # Google Project ID
  region      = "us-west1"
}

#--------------------------------------------------------------------------------------------------
# Random ID
#--------------------------------------------------------------------------------------------------

resource "random_id" "instance_id" {
  byte_length = 4
}

#--------------------------------------------------------------------------------------------------
# Single Instance
#--------------------------------------------------------------------------------------------------
resource "google_compute_instance" "default" {
 name         = "flask-vm-${random_id.instance_id.hex}"
 machine_type = "g1-small" # 1x1.7
 zone         = "us-west1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
      type = "pd-ssd" # SSD Drive
    }
  }
  # Use preemptible instances to save money
  scheduling {
    preemptible       = "true"
    automatic_restart = "false"
  }

  // Make sure flask is installed on all new instances for later steps
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync; pip install flask"

  metadata = {
    ssh-keys = "pephan:${file("~/.ssh/id_rsa.pub")}"
  }
  network_interface {
    network = "default"

    access_config {} # Include this section to give the VM an external ip address
  }
}

#--------------------------------------------------------------------------------------------------
# Firewall Policies
#--------------------------------------------------------------------------------------------------

resource "google_compute_firewall" "default" {
 name    = "flask-app-firewall"
 network = "default"

 allow {
   protocol = "tcp"
   ports    = ["5000"]
 }
}

#--------------------------------------------------------------------------------------------------
# Output
#--------------------------------------------------------------------------------------------------

output "public_ip" {
  value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}
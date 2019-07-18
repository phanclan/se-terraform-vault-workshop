# Coming soon!

# TERRAFORM PROJECT FILE STRUCTURE

Terraform elaborates all the files inside the working directory so it does not matter if everything is contained in a single file or divided into many, although it is convenient to organize the resources in logical groups and split them into different files. Let’s look at how we can do this effectively:

**Root level**: All tf files are contained in GCP folder

* __main.tf__: This is where I execute terraform from. It contains following sections:
  * Provider section: defines Google as the provider
  * Module section: GCP resources that points to each module in module folder
  * Output section: Displaying outputs after Terrafrom apply
* __variable.tf__: This is where I am defining all my variables that goes into main.tf. Modules variable.tf contains static values such as regions other variables that I am passing through main variables.tf.

    Only main variable.tf needs to be modified. I kept it simple so I don’t have to modify every variable file under each module.

* __backend.tf__: For capturing and saving tfstate on Google Storage bucket, that I can share with other developers.

## Module Folders: I am using three main modules here. Global, ue1 and uw1

* __global__ module has resources that are not region specific such as VPC Network, firewall, rules
* __uw1__ and __ue1__ module(s) has resources that are region based. The module creates four sub-networks (two public and two private network) two in each region and creating one instance of each region

Within my directory structure, I have packaged regional-based resources under one module and global resources in a separate module, that way I have to define Variable for a given region, once per module. IAM is another resource that you can define under the global module.

    I am running terraform init, plan and apply from main folder where I have defined all GCP resources. I will post another article in the future dedicated to Terraform modules, when & why it is best to use modules and which resources should be packaged in a module.

# Main.tf

__Main.tf__ creates all GCP resources that are defined under each module folder. The source is pointing to a relative path with the directory structure. You can also store modules on VCS such as GitHub.

```
provider "google" {
  project     = "${var.var_project}"
}
module "vpc" {
  source = "../modules/global" 
  env                   = "${var.var_env}"
  company               = "${var.var_company}"
  var_uc1_public_subnet = "${var.uc1_public_subnet}"
  var_uc1_private_subnet= "${var.uc1_private_subnet}"
  var_ue1_public_subnet = "${var.ue1_public_subnet}"
  var_ue1_private_subnet= "${var.ue1_private_subnet}"
}
module "uc1" {
  source                = "../modules/uc1"
  network_self_link     = "${module.vpc.out_vpc_self_link}"
  subnetwork1           = "${module.uc1.uc1_out_public_subnet_name}"
  env                   = "${var.var_env}"
  company               = "${var.var_company}"
  var_uc1_public_subnet = "${var.uc1_public_subnet}"
  var_uc1_private_subnet= "${var.uc1_private_subnet}"
}
module "ue1" {
  source                = "../modules/ue1"
  network_self_link     = "${module.vpc.out_vpc_self_link}"
  subnetwork1           = "${module.ue1.ue1_out_public_subnet_name}"
  env                   = "${var.var_env}"
  company               = "${var.var_company}"
  var_ue1_public_subnet = "${var.ue1_public_subnet}"
  var_ue1_private_subnet= "${var.ue1_private_subnet}"
}
######################################################################
# Display Output Public Instance
######################################################################
output "uc1_public_address"  { value = "${module.uc1.uc1_pub_address}"}
output "uc1_private_address" { value = "${module.uc1.uc1_pri_address}"}
output "ue1_public_address"  { value = "${module.ue1.ue1_pub_address}"}
output "ue1_private_address" { value = "${module.ue1.ue1_pri_address}"}
output "vpc_self_link" { value = "${module.vpc.out_vpc_self_link}"}
```

# Variable.tf

I have used variables for CIDR range for each sub-network, project name. I am also using variables to name resources gcp resources, so that I can easily identify which environment the resource belongs to. All variables are defined in the variables.tf file. Every variable is of type String.

```
variable "var_project" {
        default = "project-name"
    }
variable "var_env" {
        default = "dev"
    }
variable "var_company" { 
        default = "company-name"
    }
variable "uc1_private_subnet" {
        default = "10.26.1.0/24"
    }
variable "uc1_public_subnet" {
        default = "10.26.2.0/24"
    }
variable "ue1_private_subnet" {
        default = "10.26.3.0/24"
    }
variable "ue1_public_subnet" {
        default = "10.26.4.0/24"
    }
```

# VPC.tf

In the VPC file, I configured routing-type as global and disabled auto creation of sub-networks, because GCP creates sub-networks in every region during VPC creation if not disabled. 

I also create and attach Firewall to the VPC along with firewall rules to allow icmp, tcp and udp ports within internal network and external ssh access to my bastion host.

```
resource "google_compute_network" "vpc" {
  name          =  "${format("%s","${var.company}-${var.env}-vpc")}"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}
resource "google_compute_firewall" "allow-internal" {
  name    = "${var.company}-fw-allow-internal"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  source_ranges = [
    "${var.var_uc1_private_subnet}",
    "${var.var_ue1_private_subnet}",
    "${var.var_uc1_public_subnet}",
    "${var.var_ue1_public_subnet}"
  ]
}
resource "google_compute_firewall" "allow-http" {
  name    = "${var.company}-fw-allow-http"
  network = "${google_compute_network.vpc.name}"
allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["http"] 
}
resource "google_compute_firewall" "allow-bastion" {
  name    = "${var.company}-fw-allow-bastion"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["ssh"]
  }
```

# Network.tf

In the network.tf file, I have set up public and private sub-network and attaching each sub-network to myVPC. The values for regions are coming out of variables.tf files defined within each sub-module folder (not shown here). I have two network.tf files one each module folder, the difference between the two is region us-east vs us-central.

```
resource "google_compute_subnetwork" "public_subnet" {
  name          =  "${format("%s","${var.company}-${var.env}-${var.region_map["${var.var_region_name}"]}-pub-net")}"
  ip_cidr_range = "${var.var_uc1_public_subnet}"
  network       = "${var.network_self_link}"
  region        = "${var.var_region_name}"
}
resource "google_compute_subnetwork" "private_subnet" {
  name          =  "${format("%s","${var.company}-${var.env}-${var.region_map["${var.var_region_name}"]}-pri-net")}"
  ip_cidr_range = "${var.var_uc1_private_subnet}"
  network      = "${var.network_self_link}"
  region        = "${var.var_region_name}"
}
```

# Instance.tf

Here, I am creating a Ubuntu virtual machine instance and a network interface within the sub-network and then I am attaching the network interface to the instance. I am also running a userdata script which installs nginx as part of the instance creation and boot. I have two interface.tf files one each module folder, the difference between the two is region us-east vs us-central.

```
resource "google_compute_instance" "default" {
  name         = "${format("%s","${var.company}-${var.env}-${var.region_map["${var.var_region_name}"]}-instance1")}"
  machine_type  = "n1-standard-1"
  #zone         =   "${element(var.var_zones, count.index)}"
  zone          =   "${format("%s","${var.var_region_name}-b")}"
  tags          = ["ssh","http"]
  boot_disk {
    initialize_params {
      image     =  "centos-7-v20180129"     
    }
  }
labels {
      webserver =  "true"     
    }
metadata {
        startup-script = 
<<SCRIPT        apt-get -y update
        apt-get -y install nginx
        export HOSTNAME=$(hostname | tr -d '\n')
        export PRIVATE_IP=$(curl -sf -H 'Metadata-Flavor:Google' 
http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip | tr -d '\n')
        echo "Welcome to $HOSTNAME - $PRIVATE_IP" > /usr/share/nginx/www/index.html
        service nginx start
       
 SCRIPT    } 
network_interface {
    subnetwork = "${google_compute_subnetwork.public_subnet.name}"
    access_config {
      // Ephemeral IP
    }
  }
}
```
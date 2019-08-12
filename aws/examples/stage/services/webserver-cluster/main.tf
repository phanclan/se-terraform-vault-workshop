# -------------------------------------------------------------------------------------------------
# CONFIGURE AWS CONNECTION
# -------------------------------------------------------------------------------------------------

provider "aws" {
  region = "us-east-2"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"
  cluster_name = "webservers-stage"
}

output "clb_dns_name" {
  value = module.webserver_cluster.clb_dns_name
  description = "The fqdn of the load balancer"
}
#--- A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb-sg" {
  name = "${var.name_prefix}-sg"
  description = "Used in the terraform"
  vpc_id = "${module.vpc_usw2-1.vpc_id}"
  # HTTP access from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
}

#------------------------------------------------------------------------------
# Configuration for ELB. Uncomment if desired.
#------------------------------------------------------------------------------

# resource "aws_elb" "web" {
#   name = "tf-${var.prefix}-${var.env}-example-elb"

#   # The same availability zone as our instances
#   subnets = "${module.vpc_usw2-1.public_subnets}"
#   security_groups = [ "${aws_security_group.elb-sg.id}" ]

#   listener {
#     instance_port     = 80
#     instance_protocol = "http"
#     lb_port           = 80
#     lb_protocol       = "http"
#   }

#   # The instances are registered automatically
#   instances = "${aws_instance.vpc_usw2-1_pri_ubuntu.*.id}"
# }


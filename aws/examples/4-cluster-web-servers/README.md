1. Auto scaling group
    1. lifecycle - control how resources are created and destroyed
        1. `create_before_destroy = true` create new resources before destroying old ones (not default)


A data source represents a piece of read-only information that is fetched from the provider (in this case, AWS) every time you run Terraform. Adding a data source to your Terraform configurations does not create anything new; it’s just a way to query the provider’s APIs for data and to make that data available to the rest of your Terraform code. Each Terraform provider exposes a variety of data sources. For example, the AWS provider includes data sources to look up VPC data, subnet data, AMI IDs, IP address ranges, the current user’s identity, and much more.

1. Use `aws_autoscaling_group` resource `load_balancers` parameter to register each instance to CLB.
1. `health_check_type = "ELB"` is more robust than default of EC2.
1. Output dns name of ELB.
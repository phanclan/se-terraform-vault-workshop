Adding a reference from one resource to another creates an implicit dependency. 
Terraform parses these dependencies, builds a dependency graph from them, and uses that to automatically figure out in what order it should create resources. 
For example, if you were to deploy this code from scratch, Terraform would know it needs to create the security group before the EC2 Instance, since the EC2 Instance references the ID of the security group.

When Terraform walks your dependency tree, it will create as many resources in parallel as it can, which means it can apply your changes fairly efficiently. That’s the beauty of a declarative language: you just specify what you want and Terraform figures out the most efficient way to make it happen.

If you run the `apply` command, you’ll see that Terraform wants to add a security group and replace the EC2 Instance with a new Instace that has the new user data:
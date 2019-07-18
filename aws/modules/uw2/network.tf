resource "aws_vpc" "workshop" {
  cidr_block       = "${var.address_space}.0.0/16"
  tags = {
    Name = "${var.prefix}-workshop"
    environment = "Production"
  }
}

resource "aws_internet_gateway" "main-gw" {
    vpc_id = "${aws_vpc.workshop.id}"

}

resource "aws_route_table" "main-public" {
    vpc_id = "${aws_vpc.workshop.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.main-gw.id}"
    }
}

resource "aws_route_table_association" "main-public-1-a" {
    subnet_id = "${aws_subnet.subnet.id}"
    route_table_id = "${aws_route_table.main-public.id}"
}

resource "aws_security_group" "vault-sg" {
  name        = "${var.prefix}-sg"
  description = "Vault Security Group"
  vpc_id      = "${aws_vpc.workshop.id}"

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "mysql-workshop-sg" {
  name        = "${var.prefix}-mysql-sg"
  description = "Mysql Security Group"
  vpc_id      = "${aws_vpc.workshop.id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


resource "aws_subnet" "subnet" {
  vpc_id     = "${aws_vpc.workshop.id}"
  availability_zone = "${var.region}a"
  cidr_block = "${var.subnet_prefix}"

  tags = {
    Name = "tf-${var.prefix}-${var.env}-workshop"
    TTL = "72"
    owner = "team-se@hashicorp.com"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = "${aws_vpc.workshop.id}"
  availability_zone = "${var.region}b"
  cidr_block = "${var.address_space}.11.0/24"

  tags = {
    Name = "${var.prefix}-workshop-subnet"
  }
}


# Data sources for network resources
data "aws_vpc" "main" {
  filter {
    name   = "tag:Environment"
    values = [local.environment]
  }
}

data "aws_subnet" "private" {
  filter {
    name   = "tag:Environment"
    values = [local.environment]
  }

  filter {
    name   = "tag:Type"
    values = ["Private"]
  }
}

data "aws_subnet" "public" {
  count = 2

  filter {
    name   = "tag:Environment"
    values = [local.environment]
  }

  filter {
    name   = "tag:Type"
    values = ["Public"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

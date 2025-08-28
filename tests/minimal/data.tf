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

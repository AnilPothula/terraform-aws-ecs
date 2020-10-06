data "aws_vpc" "core" {
  filter {
    name   = "tag:Name"
    values = ["Core"]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.core.id

  filter {
    name   = "tag:Name"
    values = ["Private-*"]
  }
}

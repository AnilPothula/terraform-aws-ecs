data "aws_ami" "latest_ecs" {
  most_recent = true
  owners      = ["591542846629"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

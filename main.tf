locals {
  name = var.name != null ? var.name : "Core-${random_id.rand.0.dec}"
}

resource "random_id" "rand" {
  count       = var.name == null ? 1 : 0
  byte_length = 4
}

module "capacity_provider_asg" {
  source = "./../terraform-aws-asg"
  # version             = "~> 1.0"

  name                     = "${local.name}-ASG"
  vpc_zone_identifier      = var.vpc_zone_identifier
  max_size                 = var.max_size
  iam_instance_profile_arn = var.iam_instance_profile_arn != null ? var.iam_instance_profile_arn : aws_iam_role.instance_role.0.arn
  asg_tags                 = merge(var.tags, { key = "AmazonECSManaged" })

  # TODO spot options for in ASG ? or do we do this in cluster ?
  # TODO other valid asg options, iops ?
  launch_template = {
    image_id      = data.aws_ami.latest_ecs.id
    instance_tags = merge(var.tags, { key = "AmazonECSManaged" })
    volume_tags   = merge(var.tags, { key = "AmazonECSManaged" })
    instance_type = var.instance_type
  }
}

resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = "${local.name}-CP"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = module.capacity_provider_asg.asg_arn
    managed_termination_protection = var.managed_termination_protection

    # TODO managed_scaling as dynamic block with lookups for values
    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 10
    }
  }
}

resource "aws_iam_role" "instance_role" {
  count = var.iam_instance_profile_arn == null ? 1 : 0
  name  = "${local.name}-ECS-Instance-Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = merge(var.tags, { "Name" = "${local.name}-ECS-Instance-Role" })
}

resource "aws_iam_role_policy_attachment" "instance_role_ssm_core" {
  count      = var.iam_instance_profile_arn == null ? 1 : 0
  role       = aws_iam_role.instance_role.0.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "instance_role_cw" {
  count      = var.iam_instance_profile_arn == null ? 1 : 0
  role       = aws_iam_role.instance_role.0.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "instance_role_ecs" {
  count      = var.iam_instance_profile_arn == null ? 1 : 0
  role       = aws_iam_role.instance_role.0.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "instance_profile" {
  count = var.iam_instance_profile_arn == null ? 1 : 0
  name  = "${local.name}-ECS-Instance-Profile"
  role  = aws_iam_role.instance_role.0.name
}

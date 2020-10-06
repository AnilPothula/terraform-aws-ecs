locals {
  name = var.name != null ? var.name : "Core-${random_id.rand.dec}"
}

resource "random_id" "rand" {
  byte_length = 4
}

# TODO count on capacity provider & ASG & IAM when fargate or fargate spot is selection
module "capacity_provider_asg" {
  source = "./../terraform-aws-asg"
  # version             = "~> 1.0"

  # TODO add other valid asg options

  name                     = "${local.name}"
  vpc_zone_identifier      = var.vpc_zone_identifier
  max_size                 = var.max_size
  protect_from_scale_in    = var.managed_termination_protection == "ENABLED" ? true : false
  iam_instance_profile_arn = var.iam_instance_profile_arn != null ? var.iam_instance_profile_arn : aws_iam_instance_profile.instance_profile.0.arn
  asg_tags                 = merge(var.tags, { "AmazonECSManaged" = "" })

  launch_template = {
    image_id      = data.aws_ami.latest_ecs.id
    instance_tags = merge(var.tags, { "AmazonECSManaged" = "" })
    volume_tags   = merge(var.tags, { "AmazonECSManaged" = "" })
    instance_type = var.instance_type

    spot_options = length(var.spot_options) != 0 ? {
      block_duration_minutes = lookup(var.spot_options, "block_duration_minutes", null)
      max_price              = lookup(var.spot_options, "max_price", null)
    } : null
  }
}

resource "aws_ecs_capacity_provider" "capacity_provider" {
  name       = "${local.name}-CP"
  depends_on = [module.capacity_provider_asg]

  auto_scaling_group_provider {
    auto_scaling_group_arn         = module.capacity_provider_asg.asg_arn
    managed_termination_protection = var.managed_termination_protection

    dynamic "managed_scaling" {
      for_each = length(var.managed_scaling) != 0 ? [var.managed_scaling] : []

      content {
        maximum_scaling_step_size = lookup(managed_scaling.value, "maximum_scaling_step_size", null)
        minimum_scaling_step_size = lookup(managed_scaling.value, "minimum_scaling_step_size", null)
        status                    = lookup(managed_scaling.value, "status", null)
        target_capacity           = lookup(managed_scaling.value, "target_capacity", null)
      }
    }
  }

  tags = var.tags
}

resource "aws_iam_role" "instance_role" {
  count = var.iam_instance_profile_arn == null ? 1 : 0
  name  = "${local.name}-Instance-Role"

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

  tags = merge(var.tags, { "Name" = "${local.name}-Instance-Role" })
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
  name  = "${local.name}-Instance-Profile"
  role  = aws_iam_role.instance_role.0.name
}

resource "aws_iam_service_linked_role" "ecs" {
  aws_service_name = "ecs.amazonaws.com"
}

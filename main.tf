locals {
  name = var.name != null ? var.name : "Core-${random_id.rand.dec}"
}

resource "random_id" "rand" {
  byte_length = 4
}

#Capacity Provider
module "capacity_provider_asg" {
  source = "./../terraform-aws-asg"
  # version             = "~> 1.0"
  count = var.create_capacity_provider ? 1 : 0

  name                     = "${local.name}"
  vpc_zone_identifier      = var.vpc_zone_identifier
  min_size                 = var.cp_min_size
  desired_capacity         = var.cp_desired_capacity
  max_size                 = var.cp_max_size
  protect_from_scale_in    = var.cp_managed_termination_protection == "ENABLED" ? true : false
  iam_instance_profile_arn = var.iam_instance_profile_arn != null ? var.iam_instance_profile_arn : aws_iam_instance_profile.instance_profile.0.arn
  asg_tags                 = merge(var.tags, { "AmazonECSManaged" = "" })

  launch_template = {
    image_id      = data.aws_ami.latest_ecs.id
    instance_type = var.cp_instance_type
    #TODO security_group_ids
    spot           = var.cp_spot
    spot_max_price = var.cp_spot_max_price
    instance_tags  = merge(var.tags, { "AmazonECSManaged" = "" })
    volume_tags    = merge(var.tags, { "AmazonECSManaged" = "" })
  }
}

resource "aws_ecs_capacity_provider" "capacity_provider" {
  count      = var.create_capacity_provider ? 1 : 0
  depends_on = [module.capacity_provider_asg]
  name       = "${local.name}-CP"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = module.capacity_provider_asg.0.asg_arn
    managed_termination_protection = var.cp_managed_termination_protection

    dynamic "managed_scaling" {
      for_each = length(var.cp_managed_scaling) != 0 ? [var.cp_managed_scaling] : []

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

#Cluster
resource "aws_ecs_cluster" "cluster" {
  depends_on         = [aws_ecs_capacity_provider.capacity_provider]
  name               = local.name
  capacity_providers = var.create_capacity_provider ? concat(["${local.name}-CP"], [for cp in var.capacity_providers : cp.name]) : [for cp in var.capacity_providers : cp.name]
  #TODO settings
  #TODO default_capacity_provider_strategy
  tags = var.tags
}

# IAM
resource "aws_iam_role" "instance_role" {
  count = var.iam_instance_profile_arn == null && var.create_capacity_provider ? 1 : 0
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
      "Effect": "Allow"
    }
  ]
}
EOF

  tags = merge(var.tags, { "Name" = "${local.name}-Instance-Role" })
}

resource "aws_iam_role_policy_attachment" "instance_role_ssm_core" {
  count      = var.iam_instance_profile_arn == null && var.create_capacity_provider ? 1 : 0
  role       = aws_iam_role.instance_role.0.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "instance_role_cw" {
  count      = var.iam_instance_profile_arn == null && var.create_capacity_provider ? 1 : 0
  role       = aws_iam_role.instance_role.0.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "instance_role_ecs" {
  count      = var.iam_instance_profile_arn == null && var.create_capacity_provider ? 1 : 0
  role       = aws_iam_role.instance_role.0.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "instance_profile" {
  count = var.iam_instance_profile_arn == null && var.create_capacity_provider ? 1 : 0
  name  = "${local.name}-Instance-Profile"
  role  = aws_iam_role.instance_role.0.name
}

# resource "aws_iam_service_linked_role" "ecs" {
#   aws_service_name = "ecs.amazonaws.com"
# }

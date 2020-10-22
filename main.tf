locals {
  name = var.name != null ? var.name : "Core-${random_id.rand.dec}"
}

resource "random_id" "rand" {
  byte_length = 4
}

#Capacity Provider
module "capacity_provider_asg" {
  source  = "coresolutions-ltd/asg/aws"
  version = "1.0.6"

  count = var.create_capacity_provider ? 1 : 0

  name                     = "${local.name}-CP"
  vpc_zone_identifier      = var.cp_vpc_zone_identifier
  min_size                 = var.cp_min_size
  desired_capacity         = var.cp_desired_capacity
  max_size                 = var.cp_max_size
  protect_from_scale_in    = var.cp_managed_termination_protection == "ENABLED" ? true : false
  iam_instance_profile_arn = var.cp_iam_instance_profile_arn == null ? aws_iam_instance_profile.instance_profile.0.arn : var.cp_iam_instance_profile_arn
  asg_tags                 = merge(var.tags, { "AmazonECSManaged" = "" })

  launch_template = {
    image_id           = data.aws_ami.latest_ecs.id
    instance_type      = var.cp_instance_type
    security_group_ids = var.cp_associate_public_ip_address ? [] : var.cp_security_group_ids
    spot               = var.cp_spot
    spot_max_price     = var.cp_spot_max_price
    instance_tags      = merge(var.tags, { "AmazonECSManaged" = "" })
    volume_tags        = merge(var.tags, { "AmazonECSManaged" = "" })

    network_interface = var.cp_associate_public_ip_address ? {
      delete_on_termination       = true
      associate_public_ip_address = true
      security_groups             = var.cp_security_group_ids

    } : null

    user_data = base64encode(
      <<EOF
#!/bin/bash
echo ECS_CLUSTER=${local.name} >> /etc/ecs/ecs.config

${var.cp_user_data}

EOF
    )
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
  count      = var.create_cluster ? 1 : 0
  depends_on = [aws_ecs_capacity_provider.capacity_provider]

  name               = local.name
  capacity_providers = var.create_capacity_provider ? concat(["${local.name}-CP"], var.capacity_providers) : var.capacity_providers

  dynamic "setting" {
    for_each = var.container_insights ? [1] : []

    content {
      name  = "containerInsights"
      value = "enabled"
    }
  }

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategies
    iterator = cp

    content {
      capacity_provider = lookup(cp.value, "capacity_provider", null)
      weight            = lookup(cp.value, "weight", null)
      base              = lookup(cp.value, "base", null)
    }
  }

  tags = var.tags
}

#Tasks
resource "aws_ecs_task_definition" "tasks" {
  count = length(var.tasks)

  family                   = lookup(var.tasks[count.index], "family", null)
  container_definitions    = lookup(var.tasks[count.index], "container_definitions", null)
  task_role_arn            = lookup(var.tasks[count.index], "task_role_arn", null)
  execution_role_arn       = lookup(var.tasks[count.index], "execution_role_arn", null)
  network_mode             = lookup(var.tasks[count.index], "network_mode", null)
  ipc_mode                 = lookup(var.tasks[count.index], "ipc_mode", null)
  pid_mode                 = lookup(var.tasks[count.index], "pid_mode", null)
  cpu                      = lookup(var.tasks[count.index], "cpu", null)
  memory                   = lookup(var.tasks[count.index], "memory", null)
  requires_compatibilities = lookup(var.tasks[count.index], "requires_compatibilities", null)
  tags                     = var.tags

  dynamic "volume" {
    for_each = lookup(var.tasks[count.index], "volumes", [])

    content {
      name      = lookup(volume.value, "name", null)
      host_path = lookup(volume.value, "host_path", null)

      dynamic "docker_volume_configuration" {
        for_each = lookup(volume.value, "docker_volume_configuration", null) != null ? [volume.value.docker_volume_configuration] : []

        content {
          scope         = lookup(docker_volume_configuration.value, "scope", null)
          autoprovision = lookup(docker_volume_configuration.value, "autoprovision", null)
          driver        = lookup(docker_volume_configuration.value, "driver", null)
          driver_opts   = lookup(docker_volume_configuration.value, "driver_opts", null)
          labels        = lookup(docker_volume_configuration.value, "labels", null)
        }
      }

      dynamic "efs_volume_configuration" {
        for_each = lookup(volume.value, "efs_volume_configuration", null) != null ? [volume.value.efs_volume_configuration] : []

        content {
          file_system_id          = lookup(efs_volume_configuration.value, "file_system_id", null)
          root_directory          = lookup(efs_volume_configuration.value, "root_directory", null)
          transit_encryption      = lookup(efs_volume_configuration.value, "transit_encryption", null)
          transit_encryption_port = lookup(efs_volume_configuration.value, "transit_encryption_port ", null)

          dynamic "authorization_config" {
            for_each = lookup(volume.value.efs_volume_configuration, "authorization_config", null) != null ? [volume.value.efs_volume_configuration.authorization_config] : []

            content {
              access_point_id = lookup(authorization_config.value, "access_point_id", null)
              iam             = lookup(authorization_config.value, "iam", null)
            }
          }
        }
      }
    }
  }

  dynamic "placement_constraints" {
    for_each = lookup(var.tasks[count.index], "placement_constraints", [])

    content {
      type       = lookup(placement_constraints.value, "type", null)
      expression = lookup(placement_constraints.value, "expression", null)
    }
  }

  dynamic "proxy_configuration" {
    for_each = lookup(var.tasks[count.index], "proxy_configuration", null) != null ? [var.tasks[count.index].proxy_configuration] : []

    content {
      container_name = lookup(proxy_configuration.value, "container_name", null)
      properties     = lookup(proxy_configuration.value, "properties", null)
      type           = lookup(proxy_configuration.value, "type", null)
    }
  }

  dynamic "inference_accelerator" {
    for_each = lookup(var.tasks[count.index], "inference_accelerators", [])

    content {
      device_name = lookup(inference_accelerator.value, "device_name", null)
      device_type = lookup(inference_accelerator.value, "device_type", null)
    }
  }
}

#Services
resource "aws_ecs_service" "services" {
  count      = var.create_services ? length(var.tasks) : 0
  depends_on = [aws_ecs_cluster.cluster, aws_ecs_task_definition.tasks]

  cluster                            = var.create_cluster ? coalesce(var.services_cluster, aws_ecs_cluster.cluster.0.arn) : var.services_cluster
  task_definition                    = aws_ecs_task_definition.tasks[count.index].arn
  name                               = lookup(var.tasks[count.index], "family", null)
  deployment_maximum_percent         = lookup(var.tasks[count.index], "deployment_maximum_percent", null)
  deployment_minimum_healthy_percent = lookup(var.tasks[count.index], "deployment_minimum_healthy_percent", null)
  desired_count                      = lookup(var.tasks[count.index], "desired_count", null)
  enable_ecs_managed_tags            = lookup(var.tasks[count.index], "enable_ecs_managed_tags", null)
  force_new_deployment               = lookup(var.tasks[count.index], "force_new_deployment", null)
  health_check_grace_period_seconds  = lookup(var.tasks[count.index], "health_check_grace_period_seconds", null)
  launch_type                        = lookup(var.tasks[count.index], "launch_type", null)
  platform_version                   = lookup(var.tasks[count.index], "platform_version", null)
  scheduling_strategy                = lookup(var.tasks[count.index], "scheduling_strategy", null)
  propagate_tags                     = lookup(var.tasks[count.index], "propagate_tags", null)
  iam_role                           = lookup(var.tasks[count.index], "iam_role", null)
  tags                               = var.tags

  dynamic "capacity_provider_strategy" {
    for_each = lookup(var.tasks[count.index], "capacity_provider_strategies", [])

    content {
      capacity_provider = lookup(capacity_provider_strategy.value, "capacity_provider", null)
      weight            = lookup(capacity_provider_strategy.value, "weight", null)
      base              = lookup(capacity_provider_strategy.value, "base", null)
    }
  }

  dynamic "deployment_controller" {
    for_each = lookup(var.tasks[count.index], "deployment_controller", null) != null ? [var.tasks[count.index].deployment_controller] : []

    content {
      type = deployment_controller.value
    }
  }

  dynamic "load_balancer" {
    for_each = lookup(var.tasks[count.index], "load_balancers", [])

    content {
      elb_name         = lookup(load_balancer.value, "elb_name", null)
      target_group_arn = lookup(load_balancer.value, "target_group_arn", null)
      container_name   = lookup(load_balancer.value, "container_name", null)
      container_port   = lookup(load_balancer.value, "container_port", null)
    }
  }

  dynamic "network_configuration" {
    for_each = lookup(var.tasks[count.index], "network_configuration", null) != null ? [var.tasks[count.index].network_configuration] : []

    content {
      subnets          = lookup(network_configuration.value, "subnets", null)
      security_groups  = lookup(network_configuration.value, "security_groups", null)
      assign_public_ip = lookup(network_configuration.value, "assign_public_ip", null)
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = lookup(var.tasks[count.index], "ordered_placement_strategy", [])

    content {
      type  = lookup(ordered_placement_strategy.value, "type", null)
      field = lookup(ordered_placement_strategy.value, "field", null)
    }
  }

  dynamic "placement_constraints" {
    for_each = lookup(var.tasks[count.index], "placement_constraints", [])

    content {
      type       = lookup(placement_constraints.value, "type", null)
      expression = lookup(placement_constraints.value, "expression", null)
    }
  }

  dynamic "service_registries" {
    for_each = lookup(var.tasks[count.index], "service_registries", null) != null ? [var.tasks[count.index].service_registries] : []

    content {
      registry_arn   = lookup(service_registries.value, "registry_arn", null)
      port           = lookup(service_registries.value, "port", null)
      container_port = lookup(service_registries.value, "container_port", null)
      container_name = lookup(service_registries.value, "container_name", null)
    }
  }
}

# IAM
resource "aws_iam_role" "instance_role" {
  count = var.create_capacity_provider && var.cp_iam_instance_profile_arn == null ? 1 : 0
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
  count      = var.create_capacity_provider && var.cp_iam_instance_profile_arn == null ? 1 : 0
  role       = aws_iam_role.instance_role.0.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "instance_role_ssm_ec2" {
  count      = var.create_capacity_provider && var.cp_iam_instance_profile_arn == null ? 1 : 0
  role       = aws_iam_role.instance_role.0.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "instance_role_cw" {
  count      = var.create_capacity_provider && var.cp_iam_instance_profile_arn == null ? 1 : 0
  role       = aws_iam_role.instance_role.0.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "instance_role_ecs" {
  count      = var.create_capacity_provider && var.cp_iam_instance_profile_arn == null ? 1 : 0
  role       = aws_iam_role.instance_role.0.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "instance_profile" {
  count = var.create_capacity_provider && var.cp_iam_instance_profile_arn == null ? 1 : 0
  name  = "${local.name}-Instance-Profile"
  role  = aws_iam_role.instance_role.0.name
}

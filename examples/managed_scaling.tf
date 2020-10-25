module "managed_scaling" {
  source = "coresolutions-ltd/ecs/aws"

  create_capacity_provider      = true
  create_capacity_provider_role = true
  cp_vpc_zone_identifier        = data.aws_subnet_ids.private.ids

  cp_managed_scaling = {
    maximum_scaling_step_size = 10
    minimum_scaling_step_size = 1
    status                    = "ENABLED"
    target_capacity           = 80
  }
}

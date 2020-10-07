module "basic" {
  source = "./.."

  vpc_zone_identifier = data.aws_subnet_ids.private.ids
  name                = "Testing"

  # create_capacity_provider = false
  cp_instance_type    = "t3.nano"
  cp_min_size         = 0
  cp_desired_capacity = 0
  cp_max_size         = 1
  cp_weight           = 50
  # cp_base                =

  cp_spot           = true
  cp_spot_max_price = 0.02
  #   cp_managed_termination_protection = "ENABLED"

  #   cp_managed_scaling = {
  #     maximum_scaling_step_size = 10
  #     minimum_scaling_step_size = 1
  #     status                    = "ENABLED"
  #     target_capacity           = 80
  #   }

  capacity_providers = [{
    name   = "FARGATE_SPOT"
    weight = 50
  }]
}

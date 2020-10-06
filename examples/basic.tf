module "basic" {
  source = "./.."

  vpc_zone_identifier = data.aws_subnet_ids.private.ids
  max_size            = 0
  name                = "Testing"
  instance_type       = "t2.micro"

  spot_options = {
    "block_duration_minutes" = 60
    "max_price"              = 0.01
  }
  #   managed_termination_protection = "ENABLED"

  #   managed_scaling = {
  #     maximum_scaling_step_size = 10
  #     minimum_scaling_step_size = 1
  #     status                    = "ENABLED"
  #     target_capacity           = 80
  #   }
}

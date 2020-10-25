module "cp_spot" {
  source = "coresolutions-ltd/ecs/aws"

  name = "Spot"

  create_capacity_provider       = true
  create_capacity_provider_role  = true
  cp_instance_type               = "t3.nano"
  cp_min_size                    = 1
  cp_desired_capacity            = 1
  cp_max_size                    = 1
  cp_spot                        = true
  cp_spot_max_price              = 0.02
  cp_associate_public_ip_address = true
  cp_security_group_ids          = [aws_security_group.sg.id]
  cp_vpc_zone_identifier         = data.aws_subnet_ids.public.ids
}

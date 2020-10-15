module "cp_task" {
  source = "coresolutions-ltd/ecs/aws"

  name = "Example"

  create_cluster                 = true
  create_services                = true
  create_capacity_provider       = true
  cp_instance_type               = "t3.nano"
  cp_min_size                    = 1
  cp_desired_capacity            = 1
  cp_max_size                    = 1
  cp_associate_public_ip_address = true
  cp_security_group_ids          = [aws_security_group.sg.id]
  cp_vpc_zone_identifier         = data.aws_subnet_ids.public.ids

  tasks = [{
    family                = "hello_cp"
    container_definitions = file("task.json")
    desired_count         = 1
  }]
}

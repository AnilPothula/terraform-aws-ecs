module "fargate" {
  source = "coresolutions-ltd/ecs/aws"

  name               = "Fargate"
  create_cluster     = true
  create_services    = true
  capacity_providers = ["FARGATE"]

  tasks = [{
    family                   = "hello_fargate"
    container_definitions    = file("task.json")
    desired_count            = 1
    requires_compatibilities = ["FARGATE"]
    launch_type              = "FARGATE"
    cpu                      = 256
    memory                   = 512
    network_mode             = "awsvpc"

    network_configuration = {
      subnets          = data.aws_subnet_ids.public.ids
      security_groups  = [aws_security_group.sg.id]
      assign_public_ip = true
    }
  }]
}

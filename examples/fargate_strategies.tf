module "fargate_strategies" {
  source = "coresolutions-ltd/ecs/aws"

  name            = "Fargate"
  create_cluster  = true
  create_services = true

  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

  tasks = [{
    family                   = "hello_fargate_strategies"
    container_definitions    = file("task.json")
    desired_count            = 10
    requires_compatibilities = ["FARGATE"]
    cpu                      = 256
    memory                   = 512
    network_mode             = "awsvpc"

    network_configuration = {
      subnets          = data.aws_subnet_ids.public.ids
      security_groups  = [aws_security_group.sg.id]
      assign_public_ip = true
    }

    capacity_provider_strategies = [{
      capacity_provider = "FARGATE"
      weight            = 60
      base              = 1
      },
      {
        capacity_provider = "FARGATE_SPOT"
        weight            = 40
    }]
  }]
}

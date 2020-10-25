module "secrets" {
  source = "coresolutions-ltd/ecs/aws"

  name = "Secrets"

  create_cluster                 = true
  create_services                = true
  create_capacity_provider       = true
  create_capacity_provider_role  = true
  cp_instance_type               = "t3.micro"
  cp_min_size                    = 1
  cp_desired_capacity            = 1
  cp_max_size                    = 1
  cp_associate_public_ip_address = true
  cp_security_group_ids          = [aws_security_group.sg.id]
  cp_vpc_zone_identifier         = data.aws_subnet_ids.public.ids

  tasks = [{
    family                = "secrets"
    container_definitions = file("secrets.json")
    desired_count         = 1
  }]
}

# When defining secrets in the container_definitions json a task role is required to access SSM
resource "aws_iam_role" "ecs_task_role" {
  name = "TaskRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "ecs_task_policy" {
  statement {
    actions   = ["ssm:Get*"]
    resources = ["arn:aws:ssm:region:account_id:parameter/wordpress/*"]
  }
}

resource "aws_iam_policy" "ecs_task_policy" {
  name   = "TaskPolicy"
  policy = data.aws_iam_policy_document.ecs_task_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

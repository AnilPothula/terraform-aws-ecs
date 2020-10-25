module "wordpress" {
  source = "coresolutions-ltd/ecs/aws"

  name = "Wordpress"

  create_cluster                 = true
  create_services                = true
  create_capacity_provider       = true
  create_capacity_provider_role  = true
  cp_instance_type               = "t3.nano"
  cp_spot                        = true
  cp_spot_max_price              = 0.02
  cp_min_size                    = 1
  cp_desired_capacity            = 1
  cp_max_size                    = 1
  cp_security_group_ids          = [aws_security_group.ecs_sg.id]
  cp_vpc_zone_identifier         = [data.aws_subnet.public_a.id]
  cp_associate_public_ip_address = true

  tasks = [{
    family                = "wordpress"
    container_definitions = file("wordpress.json")
    desired_count         = 1
    force_new_deployment  = true
    task_role_arn         = aws_iam_role.ecs_task_role.arn

    volumes = [{
      name = "wordpress"
      efs_volume_configuration = {
        file_system_id     = aws_efs_file_system.efs_fs.id
        transit_encryption = "ENABLED"
      }
    }]
  }]
}

#EFS
resource "aws_efs_file_system" "efs_fs" {
  encrypted = true
}

resource "aws_efs_mount_target" "efs_fs_mount_point" {
  file_system_id  = aws_efs_file_system.efs_fs.id
  subnet_id       = data.aws_subnet.public_a.id
  security_groups = [aws_security_group.efs_sg.id]
}

#SG
resource "aws_security_group" "ecs_sg" {
  name   = "Wordpress"
  vpc_id = data.aws_vpc.core.id

  tags = {
    Name = "Wordpress"
  }
}

resource "aws_security_group_rule" "ecs_http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.ecs_sg.id
}


resource "aws_security_group_rule" "ecs_allow_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.ecs_sg.id
}

resource "aws_security_group" "efs_sg" {
  name   = "EFS"
  vpc_id = data.aws_vpc.core.id

  tags = {
    Name = "EFS"
  }
}

resource "aws_security_group_rule" "efs" {
  type        = "ingress"
  from_port   = 2049
  to_port     = 2049
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.efs_sg.id
}

resource "aws_security_group_rule" "efs_allow_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.efs_sg.id
}

#IAM
resource "aws_iam_role" "ecs_task_role" {
  name = "Wordpress-ECS-Task-Role"

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
    resources = ["arn:aws:ssm:::parameter/wordpress/*"]
  }
}

resource "aws_iam_policy" "ecs_task_policy" {
  name   = "Wordpress-ECS-Task-Policy"
  policy = data.aws_iam_policy_document.ecs_task_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

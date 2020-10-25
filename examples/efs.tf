module "efs" {
  source = "coresolutions-ltd/ecs/aws"

  name = "EFS"

  create_cluster                 = true
  create_services                = true
  create_capacity_provider       = true
  create_capacity_provider_role  = true
  cp_instance_type               = "t3.nano"
  cp_min_size                    = 1
  cp_desired_capacity            = 1
  cp_max_size                    = 1
  cp_associate_public_ip_address = true
  cp_security_group_ids          = [aws_security_group.sg.id]
  cp_vpc_zone_identifier         = [data.aws_subnet.public_b.id]

  tasks = [{
    family                = "efs"
    container_definitions = file("efs.json")
    desired_count         = 1
    network_mode          = "host"

    volumes = [
      {
        name = "efs"
        efs_volume_configuration = {
          file_system_id     = aws_efs_file_system.fs.id
          transit_encryption = "ENABLED"
        }
    }]
  }]
}

resource "aws_efs_file_system" "efs_fs" {
  encrypted = true
}

resource "aws_efs_mount_target" "efs_fs_mount_point" {
  file_system_id  = aws_efs_file_system.fs.id
  subnet_id       = data.aws_subnet.public_a.id
  security_groups = [aws_security_group.efs_sg.id]
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

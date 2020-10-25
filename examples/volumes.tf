module "volumes" {
  source = "coresolutions-ltd/ecs/aws"

  name = "Volumes"

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
    family                = "hello_volumes"
    container_definitions = file("task.json")
    desired_count         = 1

    volumes = [
      {
        name      = "host_storage"
        host_path = "/ecs/service-storage"
      },
      {
        name = "docker_vol"
        docker_volume_configuration = {
          scope         = "shared"
          autoprovision = true
          driver        = "local"

          driver_opts = {
            "type"   = "nfs"
            "device" = "${aws_efs_file_system.fs.dns_name}:/"
            "o"      = "addr=${aws_efs_file_system.fs.dns_name},rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport"
          }
        }
      },
      {
        name = "efs"
        efs_volume_configuration = {
          file_system_id = aws_efs_file_system.fs.id
        }
    }]
  }]
}

resource "aws_efs_file_system" "fs" {
}

resource "aws_efs_mount_target" "mt" {
  file_system_id = aws_efs_file_system.fs.id
  subnet_id      = data.aws_subnet.public_b.id
}

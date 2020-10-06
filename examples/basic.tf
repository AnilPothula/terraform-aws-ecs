module "basic" {
  source = "./.."

  vpc_zone_identifier = data.aws_subnet_ids.private.ids
  max_size            = 0
}

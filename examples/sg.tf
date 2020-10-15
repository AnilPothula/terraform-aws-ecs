resource "aws_security_group" "sg" {
  name   = "ECS"
  vpc_id = data.aws_vpc.core.id

  tags = {
    Name = "ECS"
  }
}

resource "aws_security_group_rule" "http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "efs" {
  type        = "ingress"
  from_port   = 2049
  to_port     = 2049
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "allow_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.sg.id
}

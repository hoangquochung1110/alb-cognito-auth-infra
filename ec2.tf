resource "aws_security_group" "web_sg" {
  name        = "${var.vpc_name}-web-sg"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-web-sg"
  }
}

# Learn our public IP address
data "http" "icanhazip" {
  url = "http://icanhazip.com"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_custom_tcp" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5000
  to_port           = 5000
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_security_group" "db_sg" {
  name        = "${var.vpc_name}-db-sg"
  description = "Security Group for DB instance"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-web-sg"
  }
}

# outbound rule for db_sg
resource "aws_vpc_security_group_egress_rule" "allow_all_2" {
  security_group_id = aws_security_group.db_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql" {
  security_group_id            = aws_security_group.db_sg.id
  referenced_security_group_id = aws_security_group.db_sg.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}


data "aws_key_pair" "devkey" {
  key_name = "fcj"
}

resource "aws_instance" "web_instance" {
  ami           = local.ami
  instance_type = local.instance_type

  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.devkey.key_name

  user_data = file("user-data.sh")

  tags = local.tags
}

resource "aws_lb_target_group" "lb_tg" {
  name = "${var.project_name}-tg"

  port             = 5000
  protocol         = "HTTP"
  protocol_version = "HTTP1"
  ip_address_type  = "ipv4"

  target_type = "instance"
  vpc_id      = aws_vpc.main.id
}

# register targets
resource "aws_lb" "lb" {
  name               = "${var.project_name}-lb"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"

  security_groups = [aws_security_group.web_sg.id]
  subnets         = aws_subnet.public[*].id
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}

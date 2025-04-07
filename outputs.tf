output "ec2_instance_info" {
  value = {
    public_ip = aws_instance.web_instance.public_ip
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "load_balancer" {
  value = {
    dns = aws_lb.lb.dns_name

  }
}

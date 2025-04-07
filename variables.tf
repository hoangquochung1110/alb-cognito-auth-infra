variable project_name {
    type = string
    description = "Project name"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "Auth-at-LB"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

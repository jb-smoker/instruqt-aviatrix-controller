provider "aws" {
  region = "us-west-2"
}

variable "cidr" {
  default = "10.0.0.0/16"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.13.0"

  name = "avx-controller-vpc"
  cidr = var.cidr

  azs            = ["us-west-2a"]
  public_subnets = [cidrsubnet(var.cidr, 8, 1)]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform   = true
    Environment = "instruqt"
  }
}

resource "aws_key_pair" "aviatrix_controller" {
  key_name   = "avtx-ctrl-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBi5Pg8eGmsNOjiktdPMOxoflTaZ43A0DzZl+0l9ezGv5UJDbbZLFoQrJKuTwnc9KZRTaO6LIClU8A6fiKMid+6cn8X5+g052WP1uK7jQ9kdxnqtxQyywbZY9d7cW4tzU9bM1N3W8B59YB240aEQVFLyjgVzebUmTqIVmqLDYMEiGIgpIPFgOCUn6yM64v+yb4+dSvrB2zzjhVdTPB+RV9c6aL9GTsZftQPJ6m0TUKS9+vU9PQoY84xY3lz6wggDUU9Sx/JosQnHPf0C1oKl77a3BvV+8pdEqpkBGRUK7j/YPMX20uTw41DmwzIlwNHeOvLVGhRmX5WL9M91EClR3J9PiQxyBN3DkzbePrfm4qRUnPd5/5U4QfLghB8o4OhpFegAucYz0dBOpQcHmXPnY9A4zTDyFGX8ikBDjWmqlVLHIlSqRuXZst+C2VrHZORVZQeDNrDb2FbqoVgSrNHRJCVXuIiGDCYacJ6AExegQnaliqwjYStAz6YKbKjHQ1zxs= controller.public"
}

module "aviatrix_iam_roles" {
  source = "github.com/AviatrixSystems/terraform-modules.git//aviatrix-controller-iam-roles?ref=9137282819944a79e56d3bb5977acf14fb5d6048"
}

module "aviatrix_controller" {
  source            = "github.com/AviatrixSystems/terraform-modules.git//aviatrix-controller-build?ref=350883d4d3a07f4fa60ab9a40ac3bcec92af5e7a"
  vpc               = module.vpc.vpc_id
  type              = "BYOL" # "MeteredPlatinumCopilot"
  subnet            = module.vpc.public_subnets[0]
  keypair           = aws_key_pair.aviatrix_controller.key_name
  ec2role           = module.aviatrix_iam_roles.aviatrix-role-ec2-name
  incoming_ssl_cidr = [var.cidr, "0.0.0.0/0"]
}

output "controller_private_ip" {
  value = module.aviatrix_controller.private_ip
}

output "controller_public_ip" {
  value = module.aviatrix_controller.public_ip
}

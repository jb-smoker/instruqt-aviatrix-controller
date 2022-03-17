provider "aws" {
  region = "us-west-2"
}

data "terraform_remote_state" "aviatrix_controller" {
  backend = "local"
  config  = { path = "../" }
}

variable "admin_password" {}

module "aviatrix_controller_init" {
  source              = "github.com/AviatrixSystems/terraform-modules.git//aviatrix-controller-initialize?ref=1c39b2448d3316cd3e00479be5a18201b73988c3"
  admin_email         = "ace.lab@aviatrix.com"
  admin_password      = var.admin_password
  private_ip          = data.terraform_remote_state.aviatrix_controller.controller_private_ip
  public_ip           = data.terraform_remote_state.aviatrix_controller.controller_public_ip
  access_account_name = "aws-account"
  aws_account_id      = var.aws_account_id
  vpc_id              = data.terraform_remote_state.aviatrix_controller.controller_vpc_id
  subnet_id           = data.terraform_remote_state.aviatrix_controller.controller_subnet_id
}

output "lambda_result" {
  value = module.aviatrix_controller_init.result
}

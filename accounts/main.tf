variable "aviatrix_controller_ip" {}
variable "aviatrix_username" {}
variable "aviatrix_password" {}
variable "azure_subscription_id" {}
variable "azure_directory_id" {}
variable "azure_application_id" {}
variable "azure_application_key" {}
variable "gcp_project_id" {}
variable "gcp_credentials" {}

provider "aviatrix" {
  controller_ip = var.aviatrix_controller_ip
  username      = var.aviatrix_username
  password      = var.aviatrix_password
}

resource "aviatrix_account" "azure" {
  account_name        = "azure-account"
  cloud_type          = 8
  arm_subscription_id = var.azure_subscription_id
  arm_directory_id    = var.azure_directory_id
  arm_application_id  = var.azure_application_id
  arm_application_key = var.azure_application_key
}

resource "aviatrix_account" "gcp" {
  account_name                        = "gcp-account"
  cloud_type                          = 4
  gcloud_project_id                   = var.gcp_project_id
  gcloud_project_credentials_filepath = var.gcp_credentials
}

terraform {
  required_providers {
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = "2.21.0-6.6.ga"
    }
  }
  required_version = ">= 1.0.0"
}

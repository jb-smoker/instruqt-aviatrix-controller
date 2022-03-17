data "aws_caller_identity" "current" {
  provider = aws.east
}

# provider "google" {
#   credentials = file("../../../../_keys/aviatrix-gcp.json")
#   project     = "aviatrix-lab${replace(terraform.workspace, "pod", "")}"
#   region      = "us-central1"
# }

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_application_id
  client_secret   = var.azure_application_key
  tenant_id       = var.azure_directory_id
}

provider "aws" {
  region = var.aws_region-2
  # profile = terraform.workspace
}

provider "aws" {
  alias  = "east"
  region = "us-east-1"
  # profile = terraform.workspace
}

provider "aws" {
  alias  = "west1"
  region = "us-west-1"
  # profile = terraform.workspace
}

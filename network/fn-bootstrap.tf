resource "azurerm_storage_account" "firenet_bootstrap" {
  name                     = "${terraform.workspace}firenetbootstrap"
  resource_group_name      = azurerm_resource_group.az-test-rg.name
  location                 = var.az_region
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "firenet_bootstrap" {
  name                 = "${terraform.workspace}-firenet-bootstrap"
  storage_account_name = azurerm_storage_account.firenet_bootstrap.name
  quota                = 1
}

resource "azurerm_storage_share_directory" "firenet_bootstrap_config" {
  name                 = "config"
  share_name           = azurerm_storage_share.firenet_bootstrap.name
  storage_account_name = azurerm_storage_account.firenet_bootstrap.name
}

resource "azurerm_storage_share_directory" "firenet_bootstrap_content" {
  name                 = "content"
  share_name           = azurerm_storage_share.firenet_bootstrap.name
  storage_account_name = azurerm_storage_account.firenet_bootstrap.name
}

resource "azurerm_storage_share_directory" "firenet_bootstrap_license" {
  name                 = "license"
  share_name           = azurerm_storage_share.firenet_bootstrap.name
  storage_account_name = azurerm_storage_account.firenet_bootstrap.name
}

resource "azurerm_storage_share_directory" "firenet_bootstrap_software" {
  name                 = "software"
  share_name           = azurerm_storage_share.firenet_bootstrap.name
  storage_account_name = azurerm_storage_account.firenet_bootstrap.name
}

resource "azurerm_storage_share_file" "firenet_bootstrap_init_config" {
  name             = "init-cfg.txt"
  path             = azurerm_storage_share_directory.firenet_bootstrap_config.name
  storage_share_id = azurerm_storage_share.firenet_bootstrap.id
  source           = "./firenet_files/init-cfg.txt"
}

resource "azurerm_storage_share_file" "firenet_bootstrap_xml" {
  name             = "bootstrap.xml"
  path             = azurerm_storage_share_directory.firenet_bootstrap_config.name
  storage_share_id = azurerm_storage_share.firenet_bootstrap.id
  source           = "./firenet_files/bootstrap.xml"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.23.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "6e1c64d6-1c37-47c6-adad-c6f335b38c04"
  tenant_id       = "cc28633f-12b8-46cb-bc15-951dae239b4d"
  client_id       = "7ca17b97-4811-44b9-a5c5-0472b9085681"
  client_secret   = "K3N8Q~5iykJMciG6E96y3QI.WE7mSPWL3O4Q7bl~"
}

resource "azurerm_resource_group" "rg" {
  name     = "gr-sisger-ffaa-1258644"
  location = "chilecentral"
}

resource "azurerm_storage_account" "sa" {
  name                     = "stssisgerffaa1258644"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true
}

resource "azurerm_storage_container" "bronze" {
  name                  = "bronze"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = "sql-sisger-ffaa-1258644"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "adminffaa"
  administrator_login_password = "Admin1234!"
}

resource "azurerm_mssql_database" "dw" {
  name                 = "dw-fuerzas-armadas"
  server_id            = azurerm_mssql_server.sql_server.id
  sku_name             = "S1"
  storage_account_type = "Local"
}

resource "azurerm_mssql_firewall_rule" "allow_azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_firewall_rule" "allow_all" {
  name             = "AllowAllIPs"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "azurerm_data_factory" "adf" {
  name                = "adf-sisger-ffaa-1258644"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  identity {
    type = "SystemAssigned"
  }
}
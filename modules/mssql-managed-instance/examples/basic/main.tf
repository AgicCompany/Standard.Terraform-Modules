terraform {
  required_version = ">= 1.10.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-sqlmi-example-dev-weu-001"
  location = "westeurope"
}

# --- Network prerequisites (consumer-owned) ---------------------------------
# SQL MI needs a dedicated subnet delegated to Microsoft.Sql/managedInstances
# with an NSG and a route table attached. Azure's service-aided subnet
# configuration injects the rules it needs into both.

resource "azurerm_virtual_network" "example" {
  name                = "vnet-sqlmi-example-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "sqlmi" {
  name                 = "snet-sqlmi"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.10.0.0/26"]

  delegation {
    name = "managedinstancedelegation"

    service_delegation {
      name = "Microsoft.Sql/managedInstances"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
    }
  }
}

resource "azurerm_network_security_group" "sqlmi" {
  name                = "nsg-sqlmi-example-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_route_table" "sqlmi" {
  name                = "rt-sqlmi-example-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet_network_security_group_association" "sqlmi" {
  subnet_id                 = azurerm_subnet.sqlmi.id
  network_security_group_id = azurerm_network_security_group.sqlmi.id
}

resource "azurerm_subnet_route_table_association" "sqlmi" {
  subnet_id      = azurerm_subnet.sqlmi.id
  route_table_id = azurerm_route_table.sqlmi.id
}

# --- Managed instance -------------------------------------------------------

module "sql_managed_instance" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "sqlmi-payments-dev-weu-001"

  subnet_id          = azurerm_subnet.sqlmi.id
  sku_name           = "GP_Gen5"
  vcores             = 4
  storage_size_in_gb = 32

  azuread_administrator = {
    login_username = "sqlmi-admin"
    object_id      = data.azurerm_client_config.current.object_id
    principal_type = "User"
  }

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.sqlmi,
    azurerm_subnet_route_table_association.sqlmi,
  ]
}

output "managed_instance_id" {
  value = module.sql_managed_instance.id
}

output "managed_instance_fqdn" {
  value = module.sql_managed_instance.fqdn
}

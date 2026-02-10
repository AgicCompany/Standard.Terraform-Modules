terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-vm-example-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-example-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "snet-compute"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Generate SSH key for convenience (in production, use existing keys)
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "virtual_machine" {
  source = "../../"

  resource_group_name  = azurerm_resource_group.example.name
  location             = azurerm_resource_group.example.location
  name                 = "vm-example-dev-weu-001"
  size                 = "Standard_B1s"
  subnet_id            = azurerm_subnet.example.id
  admin_username       = "azureuser"
  admin_ssh_public_key = tls_private_key.example.public_key_openssh

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "vm_id" {
  value = module.virtual_machine.id
}

output "vm_private_ip" {
  value = module.virtual_machine.private_ip_address
}

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
  name     = "rg-vm-complete-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-complete-dev-weu-001"
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

# Generate SSH key for convenience
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "virtual_machine" {
  source = "../../"

  resource_group_name  = azurerm_resource_group.example.name
  location             = azurerm_resource_group.example.location
  name                 = "vm-complete-dev-weu-001"
  size                 = "Standard_B1s"
  subnet_id            = azurerm_subnet.example.id
  admin_username       = "azureuser"
  admin_ssh_public_key = tls_private_key.example.public_key_openssh
  zone                 = "1"

  # System-assigned identity
  enable_system_assigned_identity = true

  # Boot diagnostics (managed storage)
  enable_boot_diagnostics = true

  # Data disk
  data_disks = {
    "data" = {
      lun          = 0
      disk_size_gb = 32
    }
  }

  tags = {
    project     = "complete-example"
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

output "vm_principal_id" {
  value = module.virtual_machine.principal_id
}

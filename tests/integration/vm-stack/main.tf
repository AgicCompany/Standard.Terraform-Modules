############################################
# Integration Test: VM Stack
# Covers: linux-virtual-machine,
#          windows-virtual-machine
############################################

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
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "this" {
  name     = "rg-tftest-vm-weu-001"
  location = "westeurope"
  tags     = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Virtual Network
# -----------------------------------------------------------------------------
module "virtual_network" {
  source = "../../../modules/virtual-network"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "vnet-tftest-vm-weu-001"
  address_space       = ["10.0.0.0/16"]

  subnets = {
    snet-vms = {
      address_prefixes = ["10.0.1.0/24"]
    }
  }

  subnet_nsg_associations = {
    snet-vms = module.nsg.id
  }

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Network Security Group
# -----------------------------------------------------------------------------
module "nsg" {
  source = "../../../modules/network-security-group"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "nsg-tftest-vm-weu-001"

  security_rules = {
    allow-ssh = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow SSH within VNet"
    }
    allow-rdp = {
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow RDP within VNet"
    }
    deny-internet-inbound = {
      priority                   = 4000
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "Deny all inbound from Internet"
    }
  }

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# SSH Key for Linux VM
# -----------------------------------------------------------------------------
resource "tls_private_key" "linux" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# -----------------------------------------------------------------------------
# Password for Windows VM
# -----------------------------------------------------------------------------
resource "random_password" "windows" {
  length           = 24
  special          = true
  override_special = "!@#$%^&*"
}

# -----------------------------------------------------------------------------
# Linux Virtual Machine
# -----------------------------------------------------------------------------
module "linux_vm" {
  source = "../../../modules/linux-virtual-machine"

  resource_group_name  = azurerm_resource_group.this.name
  location             = azurerm_resource_group.this.location
  name                 = "vm-tftest-linux-weu-001"
  size                 = "Standard_B1s"
  subnet_id            = module.virtual_network.subnet_ids["snet-vms"]
  admin_username       = "azureadmin"
  admin_ssh_public_key = tls_private_key.linux.public_key_openssh

  enable_system_assigned_identity = true

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Windows Virtual Machine
# -----------------------------------------------------------------------------
module "windows_vm" {
  source = "../../../modules/windows-virtual-machine"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "vm-tftest-win-weu-001"
  size                = "Standard_B2s"
  subnet_id           = module.virtual_network.subnet_ids["snet-vms"]
  admin_username      = "azureadmin"
  admin_password      = random_password.windows.result

  enable_system_assigned_identity = true

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------
output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "vnet_id" {
  value = module.virtual_network.id
}

output "nsg_id" {
  value = module.nsg.id
}

output "linux_vm_id" {
  value = module.linux_vm.id
}

output "linux_vm_private_ip" {
  value = module.linux_vm.private_ip_address
}

output "linux_vm_principal_id" {
  value = module.linux_vm.principal_id
}

output "windows_vm_id" {
  value = module.windows_vm.id
}

output "windows_vm_private_ip" {
  value = module.windows_vm.private_ip_address
}

output "windows_vm_principal_id" {
  value = module.windows_vm.principal_id
}

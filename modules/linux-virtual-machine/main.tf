resource "azurerm_public_ip" "this" {
  count = var.enable_public_ip ? 1 : 0

  name                = "pip-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zone != null ? [var.zone] : []
  tags                = var.tags
}

resource "azurerm_network_interface" "this" {
  name                = "nic-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
    private_ip_address            = var.private_ip_address
    public_ip_address_id          = var.enable_public_ip ? azurerm_public_ip.this[0].id : null
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.private_ip_address_allocation != "Static" || var.private_ip_address != null
      error_message = "private_ip_address is required when private_ip_address_allocation is \"Static\"."
    }
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = var.size
  admin_username                  = var.admin_username
  admin_password                  = var.enable_password_auth ? var.admin_password : null
  disable_password_authentication = !var.enable_password_auth
  zone                            = var.zone
  custom_data                     = var.custom_data
  network_interface_ids           = [azurerm_network_interface.this.id]

  dynamic "admin_ssh_key" {
    for_each = var.admin_ssh_public_key != null ? [1] : []

    content {
      username   = var.admin_username
      public_key = var.admin_ssh_public_key
    }
  }

  os_disk {
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
    disk_size_gb         = var.os_disk.disk_size_gb
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }

  dynamic "identity" {
    for_each = local.identity_type != null ? [1] : []

    content {
      type         = local.identity_type
      identity_ids = length(var.user_assigned_identity_ids) > 0 ? var.user_assigned_identity_ids : null
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? [1] : []

    content {
      storage_account_uri = var.boot_diagnostics_storage_uri
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.admin_ssh_public_key != null || var.enable_password_auth
      error_message = "At least one authentication method required: provide admin_ssh_public_key or set enable_password_auth = true."
    }

    precondition {
      condition     = !var.enable_password_auth || var.admin_password != null
      error_message = "enable_password_auth = true requires admin_password to be set."
    }
  }
}

resource "azurerm_managed_disk" "this" {
  for_each = var.data_disks

  name                 = "disk-${var.name}-${each.key}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = each.value.storage_account_type
  create_option        = "Empty"
  disk_size_gb         = each.value.disk_size_gb
  zone                 = var.zone
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  for_each = var.data_disks

  managed_disk_id    = azurerm_managed_disk.this[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.this.id
  lun                = each.value.lun
  caching            = each.value.caching
}

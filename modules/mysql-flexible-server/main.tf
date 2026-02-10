resource "azurerm_mysql_flexible_server" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = var.sku_name
  version  = var.version_number

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  zone = var.zone

  delegated_subnet_id = var.delegated_subnet_id
  private_dns_zone_id = var.delegated_subnet_id != null ? var.private_dns_zone_id : null

  dynamic "storage" {
    for_each = [var.storage]

    content {
      size_gb           = storage.value.size_gb
      iops              = storage.value.iops
      auto_grow_enabled = storage.value.auto_grow_enabled
    }
  }

  dynamic "high_availability" {
    for_each = var.high_availability != null ? [var.high_availability] : []

    content {
      mode                      = high_availability.value.mode
      standby_availability_zone = high_availability.value.standby_availability_zone
    }
  }

  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []

    content {
      day_of_week  = maintenance_window.value.day_of_week
      start_hour   = maintenance_window.value.start_hour
      start_minute = maintenance_window.value.start_minute
    }
  }

  tags = var.tags
}

resource "azurerm_mysql_flexible_database" "this" {
  for_each = var.databases

  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.this.name
  charset             = each.value.charset
  collation           = each.value.collation
}

resource "azurerm_mysql_flexible_server_firewall_rule" "this" {
  for_each = var.firewall_rules

  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.this.name
  start_ip_address    = each.value.start_ip_address
  end_ip_address      = each.value.end_ip_address
}

resource "azurerm_mysql_flexible_server_configuration" "this" {
  for_each = var.server_configurations

  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.this.name
  value               = each.value
}

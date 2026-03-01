resource "azurerm_mssql_database" "this" {
  name      = var.name
  server_id = var.server_id

  sku_name     = var.sku_name
  max_size_gb  = var.max_size_gb
  collation    = var.collation
  license_type = var.license_type

  zone_redundant     = var.enable_zone_redundancy
  geo_backup_enabled = var.enable_geo_redundant_backup
  read_scale         = var.enable_read_scale

  short_term_retention_policy {
    retention_days = var.short_term_retention_days
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = !can(regex("^HS_", var.sku_name)) || !var.enable_geo_redundant_backup
      error_message = "geo_backup_enabled is not supported for Hyperscale (HS_*) SKUs. Set enable_geo_redundant_backup = false."
    }
  }
}

# locals.tf - Local values

locals {
  # Use provided tenant_id or fall back to current subscription's tenant
  tenant_id = var.tenant_id != null ? var.tenant_id : data.azurerm_client_config.current.tenant_id
}

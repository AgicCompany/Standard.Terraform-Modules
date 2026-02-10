resource "azurerm_eventhub_namespace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku      = var.sku
  capacity = var.capacity

  minimum_tls_version      = var.minimum_tls_version
  auto_inflate_enabled     = var.auto_inflate_enabled
  maximum_throughput_units = var.auto_inflate_enabled ? var.maximum_throughput_units : null

  public_network_access_enabled = var.enable_public_access
  local_authentication_enabled  = var.enable_local_auth

  tags = var.tags
}

resource "azurerm_eventhub" "this" {
  for_each = var.event_hubs

  name         = each.key
  namespace_id = azurerm_eventhub_namespace.this.id

  partition_count   = each.value.partition_count
  message_retention = each.value.message_retention
}

resource "azurerm_eventhub_consumer_group" "this" {
  for_each = local.consumer_groups

  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = azurerm_eventhub.this[each.value.eventhub_key].name
  resource_group_name = var.resource_group_name

  user_metadata = each.value.user_metadata
}

resource "azurerm_eventhub_namespace_authorization_rule" "this" {
  for_each = var.authorization_rules

  name                = each.key
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = var.resource_group_name

  listen = each.value.listen
  send   = each.value.send
  manage = each.value.manage
}

resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = "pe-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_eventhub_namespace.this.id
    subresource_names              = ["namespace"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = var.tags
}

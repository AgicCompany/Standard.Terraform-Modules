# locals.tf - Local values

locals {
  pe_name_prefix  = coalesce(var.private_endpoint_name_prefix, "pep-${var.name}")
  psc_name_prefix = coalesce(var.private_service_connection_name_prefix, "psc-${var.name}")

  # A customer-managed key only reaches blob and file data: AzureRM hardcodes those
  # two services to the account key, and leaves queue and table data on whatever
  # these inputs say. So when a key is configured, default them to "Account" and let
  # the key cover all four services. An explicit value always wins.
  #
  # Only StorageV2 gets the flip. It is the one kind that both has queue and table
  # services and supports account-scoped keys for them: GPv1 rejects "Account"
  # outright, and FileStorage and BlockBlobStorage have no queue or table data to
  # encrypt. CMK itself requires StorageV2 or a Premium tier, so this covers every
  # realistic CMK account.
  cmk_covers_queue_and_table = var.customer_managed_key != null ? var.account_kind == "StorageV2" : false

  queue_encryption_key_type = coalesce(
    var.queue_encryption_key_type,
    local.cmk_covers_queue_and_table ? "Account" : "Service",
  )
  table_encryption_key_type = coalesce(
    var.table_encryption_key_type,
    local.cmk_covers_queue_and_table ? "Account" : "Service",
  )

  # access_tier only exists on BlobStorage, FileStorage and StorageV2 accounts. The
  # provider rejects it for any other kind in CustomizeDiff, so sending the "Hot"
  # default made BlockBlobStorage and Storage accounts fail at plan time. Send null
  # for those kinds instead; the attribute is Optional + Computed provider-side.
  access_tier = contains(["BlobStorage", "FileStorage", "StorageV2"], var.account_kind) ? var.access_tier : null

  # Determine which private endpoints to create
  private_endpoints = var.enable_private_endpoint ? {
    for subresource in ["blob", "file", "table", "queue"] :
    subresource => {
      dns_zone_id = lookup(var.private_dns_zone_ids, subresource, null)
    }
    if(
      subresource == "blob" ? var.enable_blob_private_endpoint :
      subresource == "file" ? var.enable_file_private_endpoint :
      subresource == "table" ? var.enable_table_private_endpoint :
      subresource == "queue" ? var.enable_queue_private_endpoint :
      false
    )
  } : {}
}

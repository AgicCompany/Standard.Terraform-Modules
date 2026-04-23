# locals.tf - Local values

locals {
  pe_name_prefix = coalesce(var.private_endpoint_name_prefix, "pep-${var.name}")

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

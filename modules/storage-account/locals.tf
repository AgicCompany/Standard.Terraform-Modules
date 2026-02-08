# locals.tf - Local values

locals {
  # Determine which private endpoints to create
  private_endpoints = var.enable_private_endpoints ? {
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

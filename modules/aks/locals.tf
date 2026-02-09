# locals.tf - Local values

locals {
  dns_prefix = coalesce(var.dns_prefix, var.name)
}

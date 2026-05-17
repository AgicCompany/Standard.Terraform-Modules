locals {
  effective_email_service_name = coalesce(var.email_service_name, "${var.name}-email")
  effective_domain_name        = var.enable_custom_domain ? var.domain_name : "AzureManagedDomain"
  domain_management            = var.enable_custom_domain ? "CustomerManaged" : "AzureManaged"
}

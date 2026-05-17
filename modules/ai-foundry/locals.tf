locals {
  effective_project_name = coalesce(var.project_name, "${var.name}-proj")
  pe_subresource_names   = ["amlworkspace"]
}

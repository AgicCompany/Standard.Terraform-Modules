variable "name" {
  type        = string
  description = "Peering name prefix. Creates two peerings: `{name}-local-to-remote` and `{name}-remote-to-local`."
}

variable "virtual_network_id" {
  type        = string
  description = "Resource ID of the local virtual network"
}

variable "virtual_network_resource_group_name" {
  type        = string
  description = "Resource group name of the local virtual network"
}

variable "virtual_network_name" {
  type        = string
  description = "Name of the local virtual network"
}

variable "remote_virtual_network_id" {
  type        = string
  description = "Resource ID of the remote virtual network"
}

variable "remote_virtual_network_resource_group_name" {
  type        = string
  default     = null
  description = "Resource group name of the remote virtual network (required when enable_remote_to_local = true)"
}

variable "remote_virtual_network_name" {
  type        = string
  default     = null
  description = "Name of the remote virtual network (required when enable_remote_to_local = true)"
}

variable "enable_remote_to_local" {
  type        = bool
  default     = true
  description = "Create the reverse peering (remote-to-local). Set to false when the remote VNet is managed separately."
}

variable "allow_virtual_network_access" {
  type        = bool
  default     = true
  description = "Allow access between peered VNets"
}

variable "allow_forwarded_traffic" {
  type        = bool
  default     = false
  description = "Allow forwarded traffic from remote VNet"
}

variable "allow_gateway_transit" {
  type        = bool
  default     = false
  description = "Allow gateway transit on the local VNet"
}

variable "use_remote_gateways" {
  type        = bool
  default     = false
  description = "Use remote VNet's gateway on the remote-to-local peering"
}

variable "local_use_remote_gateways" {
  type        = bool
  default     = false
  description = "Use remote VNet's gateway on the local-to-remote peering (used when local is the spoke)."
}

variable "remote_allow_gateway_transit" {
  type        = bool
  default     = false
  description = "Allow gateway transit on the remote-to-local peering (used when remote is the hub)."
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources. Included for interface consistency; VNet peering does not support tags."
}

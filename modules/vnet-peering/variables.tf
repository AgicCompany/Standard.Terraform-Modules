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
  description = "Resource group name of the remote virtual network"
}

variable "remote_virtual_network_name" {
  type        = string
  description = "Name of the remote virtual network"
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
  description = "Use remote VNet's gateway"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources. Included for interface consistency; VNet peering does not support tags."
}

# === Standard Outputs ===
output "id" {
  value       = azurerm_communication_service.this.id
  description = "Communication Service resource ID"
}

output "name" {
  value       = azurerm_communication_service.this.name
  description = "Communication Service name"
}

# === Resource-Specific Outputs ===
output "communication_service_id" {
  value       = azurerm_communication_service.this.id
  description = "Alias of id, named for clarity when consumers later add SMS/chat wiring"
}

output "email_service_id" {
  value       = azurerm_email_communication_service.this.id
  description = "Email Communication Service resource ID"
}

output "domain_id" {
  value       = azurerm_email_communication_service_domain.this.id
  description = "Email Communication Service Domain resource ID"
}

output "from_sender_domain" {
  value       = azurerm_email_communication_service_domain.this.from_sender_domain
  description = "P2 sender domain shown to recipients (RFC 5322)"
}

output "mail_from_sender_domain" {
  value       = azurerm_email_communication_service_domain.this.mail_from_sender_domain
  description = "P1 envelope sender domain (RFC 5321)"
}

output "hostname" {
  value       = azurerm_communication_service.this.hostname
  description = "Communication Service hostname (e.g. for SDK configuration)"
}

output "sender_usernames" {
  value = {
    for k, s in azurerm_email_communication_service_domain_sender_username.this :
    k => {
      id           = s.id
      username     = s.name
      from_address = "${s.name}@${azurerm_email_communication_service_domain.this.mail_from_sender_domain}"
    }
  }
  description = "Map of sender keys to { id, username, from_address }. from_address is computed as <username>@<mail_from_sender_domain>."
}

output "verification_records" {
  value = var.enable_custom_domain ? {
    domain = try(one(azurerm_email_communication_service_domain.this.verification_records[*].domain[0]), null)
    spf    = try(one(azurerm_email_communication_service_domain.this.verification_records[*].spf[0]), null)
    dkim   = try(one(azurerm_email_communication_service_domain.this.verification_records[*].dkim[0]), null)
    dkim2  = try(one(azurerm_email_communication_service_domain.this.verification_records[*].dkim2[0]), null)
    dmarc  = try(one(azurerm_email_communication_service_domain.this.verification_records[*].dmarc[0]), null)
  } : null
  description = "DNS verification records required when enable_custom_domain = true. null when using the Azure-managed domain. Each non-null sub-block contains { name, type, value, ttl }."
}

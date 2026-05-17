# communication-service-email

Provisions an Azure Communication Service plus an Email Communication Service, a single Email Domain (Azure-managed by default, customer-managed when `enable_custom_domain = true`), an arbitrary set of sender usernames, and the association between communication service and domain.

## Conventions deviating from the typical module

- `location` is required (module convention) but **not passed to the resources**. Neither `azurerm_communication_service` nor `azurerm_email_communication_service` accepts a `location` argument — Azure deploys them globally. The variable is kept on the module so consumers' standard `module "x" { location = local.location, ... }` pattern works unchanged.
- The module does not expose a private endpoint — AzureRM 4.x has no first-class private-endpoint support for Communication Services.
- The module does not export `primary_connection_string`. Use `data "azurerm_communication_service"` in the consumer if you need it, and write the result to Key Vault rather than to a Terraform output.

## Custom domain workflow

When `enable_custom_domain = true`, set `domain_name = "<your verified domain>"` (e.g. `mail.example.com`). After the first apply, Azure surfaces five DNS verification records (`domain` TXT, `spf` TXT, `dkim` TXT/CNAME, `dkim2` TXT/CNAME, `dmarc` TXT). The module exposes them as the `verification_records` output. Provision them at your DNS registrar, then re-apply to advance verification. The records also exist on the Azure-managed flow but are auto-managed and rarely needed.

## ForceNew foot-guns

- `data_location` on both the communication service and the email service is ForceNew. Changing it destroys and recreates both, which also recreates the domain and senders.
- `name` on `azurerm_email_communication_service_domain_sender_username` is ForceNew. The map keys in `sender_usernames` should be stable.
- Switching `enable_custom_domain` between true and false changes the domain name (`AzureManagedDomain` vs `<custom>`) and the `domain_management` mode, both of which are ForceNew on the domain resource. Plan accordingly.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

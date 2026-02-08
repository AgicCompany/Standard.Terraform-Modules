# Example: Complete Usage

Demonstrates network security group creation with multiple security rules including HTTPS, SSH, and a deny-all rule.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Prerequisites

- Azure subscription
- Azure CLI authenticated (`az login`)

## What This Creates

- Resource group `rg-nsg-complete-dev-weu-001`
- Network security group `nsg-complete-dev-weu-001` with rules:
  - **allow-https-inbound** (priority 100): Allow HTTPS from any source
  - **allow-ssh-inbound** (priority 200): Allow SSH from internal networks (10.0.0.0/8)
  - **deny-all-inbound** (priority 4096): Explicit deny-all for inbound traffic

## Clean Up

```bash
terraform destroy
```

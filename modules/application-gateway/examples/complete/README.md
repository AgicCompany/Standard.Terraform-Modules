# Example: Complete Usage

Deploys an Application Gateway with multiple backends, health probes, URL routing, and autoscaling.

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

- Resource group `rg-appgw-complete-dev-weu-001`
- Virtual network `vnet-appgw-complete-dev-weu-001` with address space `10.0.0.0/16`
- Subnet `snet-appgw` with address prefix `10.0.1.0/24`
- Application Gateway `agw-complete-dev-weu-001` (Standard_v2, zone-redundant)
- Public IP `pip-agw-complete-dev-weu-001`
- Two backend pools (web servers with IPs, API servers with FQDNs)
- Two backend HTTP settings (HTTP and HTTPS with health probe)
- Health probe for API backend
- Two HTTP listeners
- Two routing rules
- Redirect configuration
- Autoscale: min 2, max 10

## Clean Up

```bash
terraform destroy
```

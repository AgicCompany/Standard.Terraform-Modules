# Migration Guide

Breaking changes by module, with code snippets to preserve previous behavior when upgrading.

## aks

### v3.x → v4.0.0

Three feature flag defaults changed to align with the convention (security features default `true`, functionality features default `false`).

| Variable | Old default | New default |
|----------|------------|-------------|
| `workload_identity_enabled` | `false` | `true` |
| `enable_auto_scaling` | `true` | `false` |
| `enable_container_insights` | `true` | `false` |

**To preserve v3.x behavior:**

```hcl
module "aks" {
  source = "git::...//modules/aks?ref=aks/v4.0.0"

  # Restore previous defaults explicitly
  workload_identity_enabled = false
  enable_auto_scaling       = true
  enable_container_insights = true
  log_analytics_workspace_id = var.log_analytics_workspace_id
  # ...
}
```

**Recommended upgrade path:** Accept the new defaults. Workload identity is the modern auth pattern, and auto-scaling/insights can be enabled per-environment via tfvars.

### v2.x → v3.0.0

- `kube_config_raw` output **removed**. Use `az aks get-credentials` with Entra ID auth instead. If you reference `module.aks.kube_config_raw` anywhere, remove it.

### v1.x → v2.0.0

- `default_node_pool.zones` default changed from `["1","2","3"]` to `[]`. Multi-zone consumers must now pass zones explicitly:

```hcl
default_node_pool = {
  zones = ["1", "2", "3"]
}
```

---

## application-gateway

### v1.x → v2.0.0

- `enable_http2` default changed from `true` to `false` (functionality feature convention).

**To preserve v1.x behavior:**

```hcl
module "appgw" {
  source = "git::...//modules/application-gateway?ref=application-gateway/v2.0.0"

  enable_http2 = true
  # ...
}
```

---

## function-app

### v2.x → v3.0.0

- `enable_application_insights` default changed from `true` to `false` (functionality feature convention).

**To preserve v2.x behavior:**

```hcl
module "function_app" {
  source = "git::...//modules/function-app?ref=function-app/v3.0.0"

  enable_application_insights            = true
  application_insights_connection_string = var.appinsights_connection_string
  # ...
}
```

### v1.x → v2.0.0

- Private endpoint name changed from `pe-{name}` to `pep-{name}` (Azure CAF). **This causes resource recreation.**
- Private endpoint NIC uses deterministic name `pep-{name}-nic`.

**To preserve v1.x naming (avoid recreation):**

```hcl
module "function_app" {
  source = "git::...//modules/function-app?ref=function-app/v2.0.0"

  private_endpoint_name = "pe-${local.function_app_name}"
  # ...
}
```

**Recommended:** Accept the new naming. Run `terraform plan` to confirm only the PE is recreated (brief connectivity blip).

---

## windows-virtual-machine

### v1.x → v2.0.0

Three security features added with `default = true`. Existing VMs may be **recreated** or fail if prerequisites aren't met.

| Variable | Effect | Prerequisite |
|----------|--------|--------------|
| `enable_encryption_at_host` | Encrypts temp disks + cached data | `Microsoft.Compute/EncryptionAtHost` feature registered on subscription |
| `enable_secure_boot` | Trusted Launch — Secure Boot | Gen2 VM image |
| `enable_vtpm` | Trusted Launch — vTPM | Gen2 VM image |

**To preserve v1.x behavior:**

```hcl
module "windows_vm" {
  source = "git::...//modules/windows-virtual-machine?ref=windows-virtual-machine/v2.0.0"

  enable_encryption_at_host = false
  enable_secure_boot        = false
  enable_vtpm               = false
  # ...
}
```

**Recommended upgrade path:**
1. Ensure subscription has `EncryptionAtHost` registered: `az feature register --namespace Microsoft.Compute --name EncryptionAtHost`
2. Use a Gen2 image (the module default `2022-datacenter-g2` is already Gen2)
3. Accept the new defaults — these are security hardening features

> **Warning:** Enabling Trusted Launch (secure boot + vTPM) on an existing VM that was created without it requires VM deallocation and may cause recreation depending on the VM size and image. Test in a non-production environment first.

---

## redis-cache

### v3.x → v4.0.0

- Private endpoint name changed from `pe-` prefix to `pep-` prefix (Azure CAF). **Causes PE recreation.**
- `minimum_tls_version` variable renamed to `min_tls_version`.
- `sku_name` default changed from `Basic` to `Standard`.

**To preserve v3.x behavior:**

```hcl
module "redis" {
  source = "git::...//modules/redis-cache?ref=redis-cache/v4.0.0"

  sku_name     = "Basic"
  # Note: variable was renamed
  min_tls_version = "1.2"
  # ...
}
```

---

## Quick reference: which consumers need what

| Consumer | Module | Current pin | Target | Action needed |
|----------|--------|-------------|--------|---------------|
| siag-aks-terraform | aks | v1.5.0 | v4.0.0 | Pass `zones`, remove `kube_config_raw` refs, set feature flags |
| siag-aks-terraform | aks-node-pool | `aks/v1.5.0` (wrong!) | `aks-node-pool/v2.0.0` | Fix tag ref, pass `zones` explicitly |
| siag-fse2-infra-repo | redis-cache | v1.1.0 | v4.0.0 | Rename TLS var, accept `pep-` naming or override |

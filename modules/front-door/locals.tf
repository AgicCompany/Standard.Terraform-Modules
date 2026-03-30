locals {
  rules_flat = merge([
    for rs_key, rs in var.rule_sets : {
      for r_key, r in rs.rules : "${rs_key}/${r_key}" => merge(r, {
        rule_set_key = rs_key
        rule_key     = r_key
      })
    }
  ]...)
}

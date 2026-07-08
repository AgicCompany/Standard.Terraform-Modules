"""Pure lint checks: facts in, findings out. No I/O.

`lint()` owns pin-time internal correctness — checks 3, 5, 8, 9, 10, 11, 13. Check 2
(module existence) needs git and lives in cli.py. The `resolve_path` callable
(check 11) and `latest_tag` (check 10) are injected so this module stays pure.
"""
from packaging.version import Version, InvalidVersion

from .models import Finding, ERROR, WARN, INFO


WIDGET_TYPE_SHAPES = {                       # widget -> set of accepted type shapes
    "text": {"string", "list", "set"},
    "password": {"string"}, "code_editor": {"string"},
    "number": {"number"}, "toggle": {"bool"},
    "select": {"string", "number", "bool"},
    "multiselect": {"list", "set"}, "repeater": {"list", "set", "map"},
    "resource_picker": {"string", "list", "set"},
    "key_value_map": {"map", "object"}, "object": {"object", "map"},
}
_KNOWN_SHAPES = {"string", "number", "bool", "any", "list", "set", "map", "object"}

# Registered group vocabulary — T1 §7.1 check 9.
# Any top-level group name not in this set earns a WARN (likely a typo).
# Derived from the four canonical sidecars; extend here when a new module
# introduces a genuinely new grouping concept.
REGISTERED_GROUPS = frozenset({
    "core",        # basic identity, naming, tier — shared across modules
    "networking",  # VNet/subnet/endpoint wiring
    "security",    # auth, encryption, access control
    "monitoring",  # diagnostics, logs, metrics, alerts
    "features",    # capability toggles (e.g. blob versioning, hierarchical namespace)
    "identity",    # managed identity assignment
    "scaling",     # node counts, autoscaler settings
    "node_pool",   # AKS default node pool configuration
    "maintenance", # maintenance windows, upgrade channels
    "addons",      # AKS add-ons (ingress controller, monitoring, etc.)
    "entities",    # service-bus topics / queues / subscriptions
})


def _type_shape(type_expr: str) -> str:
    """Outer shape of a (${...}-unwrapped) HCL type: a primitive or constructor head
    token, else 'unknown'. Does NOT unwrap optional() — invalid at top level (see spec §3)."""
    head = type_expr.split("(", 1)[0].strip()
    return head if head in _KNOWN_SHAPES else "unknown"


def _check_3_coverage(sidecar, pinned):
    findings = []
    module_vars = set(pinned.variables)
    # orphan: sidecar references a var the module does not declare
    for name in sorted(sidecar.referenced_vars - module_vars):
        findings.append(Finding(family="lint", check="lint.3", severity=ERROR, name=name,
                        detail=f"variable '{name}' is referenced by the sidecar but "
                               f"absent from the module"))
    # uncovered module vars, graded by requiredness
    for name in sorted(module_vars - sidecar.referenced_vars):
        if pinned.variables[name].required:
            findings.append(Finding(family="lint", check="lint.3", severity=ERROR, name=name,
                            detail=f"required variable '{name}' is neither exposed nor "
                                   f"derived by the sidecar"))
        else:
            findings.append(Finding(family="lint", check="lint.3", severity=WARN, name=name,
                            detail=f"optional variable '{name}' is not handled by the "
                                   f"sidecar"))
    return findings


def _check_4_widget_type(sidecar, pinned):
    findings = []
    for name, widget in sorted(sidecar.variable_widgets.items()):
        accepted = WIDGET_TYPE_SHAPES.get(widget)
        if accepted is None:                         # hidden / unmapped -> skip
            continue
        var = pinned.variables.get(name)
        if var is None:                              # orphan -> check 3 owns it
            continue
        shape = _type_shape(var.type)
        if shape in ("any", "unknown"):              # any accepts all; unknown -> skip
            continue
        if shape not in accepted:
            findings.append(Finding(family="lint", check="lint.4", severity=ERROR,
                            name=name,
                            detail=f"widget '{widget}' on variable '{name}' is "
                                   f"incompatible with module type '{var.type}' "
                                   f"(shape '{shape}'; expected {sorted(accepted)})"))
    return findings


def _check_8_outputs(sidecar, pinned):
    findings = []
    for name in sorted(sidecar.displayed_outputs - pinned.outputs):
        findings.append(Finding(family="lint", check="lint.8", severity=ERROR, name=name,
                        detail=f"output '{name}' is displayed by the sidecar but not "
                               f"declared by the module"))
    for name in sorted(sidecar.displayed_outputs & pinned.sensitive_outputs):
        findings.append(Finding(family="lint", check="lint.8", severity=ERROR, name=name,
                        detail=f"output '{name}' is marked sensitive by the module and "
                               f"must not be displayed"))
    # Alias-correspondence: every public_alias must have a standard counterpart
    # with the same value expression in outputs.tf.
    # WARN not ERROR: value comparison is best-effort — opaque outputs have no
    # value_str entry, so the matcher can silently miss valid pairs. ERROR would
    # create false positives for aliases on opaque outputs.
    standard_names = sidecar.displayed_outputs - sidecar.alias_output_names
    for name in sorted(sidecar.alias_output_names):
        if name not in pinned.outputs:
            continue  # existence check above already fired — don't double-report
        if name in pinned.sensitive_outputs:
            continue  # sensitive ERROR already fired — alias WARN would be noise
        alias_fact = pinned.output_values.get(name)
        if alias_fact is None:
            continue  # no value data (parse gap) — best-effort skip
        match = any(
            pinned.output_values.get(s) is not None
            and pinned.output_values[s].value_str == alias_fact.value_str
            for s in standard_names
        )
        if not match:
            findings.append(Finding(
                family="lint", check="lint.8", severity=WARN, name=name,
                detail=f"output '{name}' is marked public_alias but no standard output "
                       f"in outputs_display shares the same value in outputs.tf"))
    return findings


def _values_are_bool(values) -> bool:
    """True iff every show_when value is a Python bool (yaml `true`/`false`)."""
    return bool(values) and all(isinstance(v, bool) for v in values)


def _check_5_show_when(sidecar, pinned):
    findings = []
    for ref in sidecar.show_when_refs:
        target = pinned.variables.get(ref.target_var)
        if target is None:
            findings.append(Finding(family="lint", check="lint.5", severity=ERROR,
                            name=ref.target_var,
                            detail=f"show_when on '{ref.owner_var}' targets variable "
                                   f"'{ref.target_var}', which the module does not declare"))
            continue
        if _values_are_bool(ref.values) != (target.type == "bool"):
            findings.append(Finding(family="lint", check="lint.5", severity=WARN,
                            name=ref.target_var,
                            detail=f"show_when value on '{ref.owner_var}' is boolean but "
                                   f"target '{ref.target_var}' is type '{target.type}' "
                                   f"(or vice-versa)"))
        # Enum-value consistency: non-bool value must be in the target's known options
        if not _values_are_bool(ref.values) and target.options:
            bad = [v for v in ref.values if v not in target.options]
            if bad:
                findings.append(Finding(family="lint", check="lint.5", severity=WARN,
                                name=ref.target_var,
                                detail=f"show_when on '{ref.owner_var}' uses value(s) "
                                       f"{bad!r} for '{ref.target_var}', which are not "
                                       f"in the module's allowed options "
                                       f"{list(target.options)!r}"))
    return findings


def _check_5_nested_show_when(sidecar):
    """Check show_when refs inside object.widget_options.fields.
    Target resolves against sibling fields, not module variables."""
    findings = []
    for ref in sidecar.nested_show_when_refs:
        if not ref.target_exists:
            findings.append(Finding(
                family="lint", check="lint.5", severity=ERROR,
                name=ref.target_field,
                detail=f"nested show_when on '{ref.parent_var}.{ref.owner_field}' "
                       f"targets field '{ref.target_field}', which is not declared "
                       f"in '{ref.parent_var}.widget_options.fields'"))
            continue
        if _values_are_bool(ref.values) != ref.target_is_toggle:
            findings.append(Finding(
                family="lint", check="lint.5", severity=WARN,
                name=ref.target_field,
                detail=f"nested show_when on '{ref.parent_var}.{ref.owner_field}' "
                       f"uses boolean value but target field '{ref.target_field}' "
                       f"widget is not 'toggle' (or vice-versa)"))
        if not _values_are_bool(ref.values) and ref.target_options:
            # target_options are pre-normalized to str by the harvester; cast values to match
            bad = [str(v) for v in ref.values if str(v) not in ref.target_options]
            if bad:
                findings.append(Finding(
                    family="lint", check="lint.5", severity=WARN,
                    name=ref.target_field,
                    detail=f"nested show_when on '{ref.parent_var}.{ref.owner_field}' "
                           f"uses value(s) {bad!r} for field '{ref.target_field}', "
                           f"which are not in its options "
                           f"{list(ref.target_options)!r}"))
    return findings


def _bare_semver(tag: str) -> str:
    """'demo/v2.0.0' -> '2.0.0'. Tolerates a missing prefix or 'v'."""
    return tag.rsplit("/", 1)[-1].lstrip("v")


def _check_10_version(sidecar, latest_tag):
    if not latest_tag:
        return []
    try:
        latest_v = Version(_bare_semver(latest_tag))
        pinned_v = Version(sidecar.module_version)
    except InvalidVersion:
        return [Finding(family="lint", check="lint.10", severity=WARN,
                        name=sidecar.module_version,
                        detail=f"module_version '{sidecar.module_version}' is not a "
                               f"parseable semver")]
    maj, minr, pat = latest_v.major, latest_v.minor, latest_v.micro
    plausible = {
        latest_v,
        Version(f"{maj + 1}.0.0"),
        Version(f"{maj}.{minr + 1}.0"),
        Version(f"{maj}.{minr}.{pat + 1}"),
    }
    if pinned_v in plausible:
        return []
    return [Finding(family="lint", check="lint.10", severity=WARN,
                    name=sidecar.module_version,
                    detail=f"pinned version '{sidecar.module_version}' is neither the "
                           f"latest tag ({_bare_semver(latest_tag)}) nor a plausible "
                           f"next bump from it")]


def _check_11_dependency_paths(sidecar, pinned, resolve_path):
    findings = []
    for path in sidecar.dependency_var_paths:
        segments = path.split(".")
        root = segments[0]
        if root not in pinned.variables:
            findings.append(Finding(family="lint", check="lint.11", severity=ERROR,
                            name=path,
                            detail=f"dependency path root '{root}' is not a module "
                                   f"variable"))
            continue
        if not resolve_path(pinned.variables[root].type, segments[1:]):
            findings.append(Finding(family="lint", check="lint.11", severity=ERROR,
                            name=path,
                            detail=f"dependency path '{path}' does not resolve through "
                                   f"the object type of variable '{root}'"))
    return findings


def _check_11_output_paths(sidecar, pinned):
    """Check dot-path keys in outputs_display resolve against object-literal outputs.
    Best-effort: skips opaque values and depth > 1."""
    findings = []
    for path in sidecar.display_output_paths:
        if "." not in path:
            continue  # not a dot-path — nothing to resolve
        base, rest = path.split(".", 1)
        if base not in pinned.outputs:
            continue  # check 8 existence owns this
        if "." in rest:
            continue  # depth > 1 — best-effort skip
        of = pinned.output_values.get(base)
        if of is None or not of.fields:
            continue  # opaque — best-effort skip
        if rest not in of.fields:
            findings.append(Finding(
                family="lint", check="lint.11", severity=ERROR, name=path,
                detail=f"dot-path '{path}' cannot be resolved: field '{rest}' not found "
                       f"in output '{base}' object literal "
                       f"(known fields: {sorted(of.fields)})"))
    return findings


def _check_13_alias_detection(sidecar, pinned):
    """Advisory: warn when two standard outputs share a value expression in outputs.tf
    but neither is marked role: public_alias (T1 §7.1 check 13).
    N>2 behavior: all duplicates report against the first occurrence; seen dict is not
    updated after a match — intentional for an advisory check."""
    findings = []
    standard_names = sorted(sidecar.displayed_outputs - sidecar.alias_output_names)
    seen = {}  # value_str -> first output name
    for name in standard_names:
        of = pinned.output_values.get(name)
        if of is None:
            continue
        if of.value_str in seen:
            other = seen[of.value_str]
            findings.append(Finding(
                family="lint", check="lint.13", severity=WARN, name=name,
                detail=f"outputs '{other}' and '{name}' share the same value expression "
                       f"in outputs.tf but neither is marked role: public_alias"))
        else:
            seen[of.value_str] = name
    return findings


def _check_9_group_names(sidecar):
    """Warn on top-level group names not in the registered vocabulary (T1 §7.1 check 9).
    A group absent from REGISTERED_GROUPS is likely a typo or an unapproved name.
    Extend REGISTERED_GROUPS when a new module introduces a legitimately new grouping concept."""
    findings = []
    for group in sorted(sidecar.group_names - REGISTERED_GROUPS):
        findings.append(Finding(
            family="lint", check="lint.9", severity=WARN, name=group,
            detail=f"group '{group}' is not in the registered group vocabulary; "
                   f"check for a typo or add it to REGISTERED_GROUPS in lint.py"))
    return findings


def lint(sidecar, pinned, latest_tag, resolve_path):
    findings = []
    findings += _check_3_coverage(sidecar, pinned)
    findings += _check_4_widget_type(sidecar, pinned)
    findings += _check_8_outputs(sidecar, pinned)
    findings += _check_5_show_when(sidecar, pinned)
    findings += _check_5_nested_show_when(sidecar)
    findings += _check_9_group_names(sidecar)
    findings += _check_10_version(sidecar, latest_tag)
    findings += _check_11_dependency_paths(sidecar, pinned, resolve_path)
    findings += _check_11_output_paths(sidecar, pinned)
    findings += _check_13_alias_detection(sidecar, pinned)
    return findings

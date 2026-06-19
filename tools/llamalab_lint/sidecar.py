"""Read a sidecar YAML into SidecarFacts."""
import yaml

from .models import SidecarFacts, ShowWhenRef, NestedShowWhenRef


def _normalize_values(raw):
    """show_when values may be a scalar or a list; normalize to a tuple."""
    if isinstance(raw, list):
        return tuple(raw)
    return (raw,)


def _harvest_show_when(variables: dict) -> list:
    """Top-level show_when only: one ShowWhenRef per target key (multiple keys = AND).
    Does NOT descend into widget_options — nested object-field show_when targets a
    sibling field, not a module variable (decision B1)."""
    refs = []
    for owner, node in variables.items():
        if not isinstance(node, dict):
            continue
        block = node.get("show_when")
        if not isinstance(block, dict):
            continue
        for target, values in block.items():
            refs.append(ShowWhenRef(owner_var=owner, target_var=target,
                                    values=_normalize_values(values)))
    return refs


def _harvest_nested_show_when(variables: dict) -> list:
    """Single-level descent: object.widget_options.fields.*.show_when.
    Each ref resolves against sibling fields, not module variables."""
    refs = []
    for parent_var, node in variables.items():
        if not isinstance(node, dict) or node.get("widget") != "object":
            continue
        fields = (node.get("widget_options") or {}).get("fields") or {}
        if not isinstance(fields, dict):
            continue
        for owner_field, field_node in fields.items():
            if not isinstance(field_node, dict):
                continue
            block = field_node.get("show_when")
            if not isinstance(block, dict):
                continue
            for target_field, raw_values in block.items():
                target_node = fields.get(target_field) or {}
                raw_opts = (target_node.get("widget_options") or {}).get("options") or []
                target_options = tuple(
                    str(o.get("value", "")) if isinstance(o, dict) else str(o)
                    for o in raw_opts
                )
                refs.append(NestedShowWhenRef(
                    parent_var=parent_var,
                    owner_field=owner_field,
                    target_field=target_field,
                    values=_normalize_values(raw_values),
                    target_exists=target_field in fields,
                    target_is_toggle=target_node.get("widget") == "toggle",
                    target_options=target_options,
                ))
    return refs


def _harvest_dependency_paths(dependencies: dict) -> list:
    """Collect dependencies.required_inputs_from_other_resources[*].variable dot-paths."""
    inputs = (dependencies or {}).get("required_inputs_from_other_resources") or []
    paths = []
    for entry in inputs:
        if isinstance(entry, dict) and isinstance(entry.get("variable"), str):
            paths.append(entry["variable"])
    return paths


def _harvest_alias_outputs(outputs_display: dict) -> set:
    """Names of outputs_display entries with role: public_alias.
    NOTE: role: public_alias always appears on flat (non-dot-path) keys in practice
    (a cross-project alias is a top-level output, never a sub-field). The split is
    defensive: if a dot-path key somehow carries the role, we record the base name."""
    aliases = set()
    for name, node in outputs_display.items():
        base = name.split(".", 1)[0]
        if isinstance(node, dict) and node.get("role") == "public_alias":
            aliases.add(base)
    return aliases


def _harvest_display_output_paths(outputs_display: dict) -> list:
    """Dot-path keys in outputs_display (keys containing a '.')."""
    return [key for key in outputs_display if "." in key]


def _harvest_widgets(variables: dict) -> dict:
    """Top-level var name -> widget string. Like _harvest_show_when, this does NOT
    descend into widget_options — nested object-field widgets are not module variables."""
    widgets = {}
    for name, node in variables.items():
        if isinstance(node, dict) and isinstance(node.get("widget"), str):
            widgets[name] = node["widget"]
    return widgets


def _harvest_group_names(variables: dict) -> frozenset:
    """Unique top-level group values from non-hidden variables (T1 §7.1 check 9)."""
    groups = set()
    for node in variables.values():
        if not isinstance(node, dict):
            continue
        if node.get("widget") == "hidden":
            continue
        group = node.get("group")
        if isinstance(group, str):
            groups.add(group)
    return frozenset(groups)


def read_sidecar(path) -> SidecarFacts:
    with open(path, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}
    metadata = data.get("metadata") or {}
    variables = data.get("variables") or {}
    outputs_display = data.get("outputs_display") or {}
    dependencies = data.get("dependencies") or {}
    referenced_vars = set(variables.keys())
    # Dot-path keys (e.g. 'identity.principal_id') collapse to the top-level
    # output name, since outputs.tf only declares the top-level output.
    displayed_outputs = {key.split(".", 1)[0] for key in outputs_display.keys()}
    return SidecarFacts(
        module_name=metadata.get("module_name"),
        module_version=metadata.get("module_version"),
        referenced_vars=referenced_vars,
        displayed_outputs=displayed_outputs,
        show_when_refs=_harvest_show_when(variables),
        dependency_var_paths=_harvest_dependency_paths(dependencies),
        variable_widgets=_harvest_widgets(variables),
        nested_show_when_refs=_harvest_nested_show_when(variables),
        alias_output_names=_harvest_alias_outputs(outputs_display),
        display_output_paths=_harvest_display_output_paths(outputs_display),
        group_names=_harvest_group_names(variables),
    )

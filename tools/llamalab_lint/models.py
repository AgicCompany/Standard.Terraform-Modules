"""Data model for llamalab-drift. Plain dataclasses + string constants."""
from dataclasses import dataclass, field

# Severity levels
ERROR = "ERROR"
WARN = "WARN"
INFO = "INFO"

# Which pass produced a finding ('pass' is a Python keyword, so: phase)
PIN = "pin"
UPGRADE = "upgrade"


class DriftError(Exception):
    """Raised for unrecoverable conditions (missing tag, unreadable HCL, etc.)."""


@dataclass(frozen=True)
class VarFact:
    type: str          # type expression, ${...}-unwrapped
    required: bool     # True iff the variable block has no 'default' key
    options: tuple = ()  # allowed values from contains([...], var.<name>); empty if none


@dataclass
class ModuleFacts:
    variables: dict                                       # name(str) -> VarFact
    outputs: set                                          # set[str]
    sensitive_outputs: set = field(default_factory=set)   # set[str]
    output_values: dict = field(default_factory=dict)     # name(str) -> OutputFact


@dataclass(frozen=True)
class ShowWhenRef:
    owner_var: str     # variable whose visibility depends on target_var
    target_var: str    # the referenced (depended-on) variable
    values: tuple      # normalized show_when value(s); a scalar becomes a 1-tuple


@dataclass(frozen=True)
class NestedShowWhenRef:
    parent_var: str        # enclosing object variable name
    owner_field: str       # field whose visibility is conditional
    target_field: str      # sibling field being tested
    values: tuple          # normalized show_when values (scalar -> 1-tuple)
    target_exists: bool    # target_field declared in the same fields dict?
    target_is_toggle: bool # target_field widget == "toggle"?
    target_options: tuple  # target's widget_options.options as strings; () if absent


@dataclass(frozen=True)
class OutputFact:
    value_str: str      # canonical comparable string — used by checks 8 alias + 13
    fields: frozenset   # top-level field names if value is an object literal {k=v,...};
                        # frozenset() when value is opaque (resource attribute access, etc.)


@dataclass
class SidecarFacts:
    module_name: str
    module_version: str
    referenced_vars: set       # set[str]  (keys under variables:)
    displayed_outputs: set     # set[str]  (top-level output names)
    show_when_refs: list = field(default_factory=list)        # list[ShowWhenRef] (top-level only)
    dependency_var_paths: list = field(default_factory=list)  # list[str]  dot-paths
    variable_widgets: dict = field(default_factory=dict)      # {top-level var: widget str}
    nested_show_when_refs: list = field(default_factory=list)      # list[NestedShowWhenRef]
    alias_output_names: set = field(default_factory=set)         # role: public_alias entries
    display_output_paths: list = field(default_factory=list)     # dot-path keys in outputs_display
    group_names: frozenset = field(default_factory=frozenset)    # top-level group values (non-hidden)


@dataclass(frozen=True)
class Finding:
    family: str        # "lint" | "drift"
    check: str         # "lint.3", "lint.11", "drift.cat1", "drift.cat2", ...
    severity: str      # ERROR | WARN | INFO
    name: str          # variable or output name
    detail: str
    phase: str = ""    # drift only: "pin" | "upgrade"; "" for lint

"""Read a framework-terraform module's variables/outputs at a git ref.

Handles python-hcl2 8.x representation quirks (verified against 8.1.2):
- block label keys are quote-wrapped: {'"name"': {body}}
- composite type expressions are wrapped in ${...}: '${map(string)}'
- '__comments__' appears at the TOP level (a sibling of 'variable'/'output'),
  so iterating d['variable']/d['output'] already skips it
- each block BODY carries '__is_block__': True; harmless to the 'default' check
"""
import subprocess
import re

import hcl2

from .models import ModuleFacts, VarFact, DriftError, OutputFact


def _strip_quotes(name: str) -> str:
    if len(name) >= 2 and name[0] == '"' and name[-1] == '"':
        return name[1:-1]
    return name


def _unwrap_type(value) -> str:
    expr = str(value).strip()
    if expr.startswith("${") and expr.endswith("}"):
        return expr[2:-1].strip()
    return expr


def _block_label_and_body(block: dict):
    """A hcl2 block dict is {'"label"': {body}}. Skip any defensive __-meta key
    and return (stripped_label, body); None if no real label is found."""
    for key, body in block.items():
        if key.startswith("__"):
            continue
        return _strip_quotes(key), body
    return None


def _extract_options(body: dict, name: str) -> tuple:
    """Return options from a self-anchored contains([...], var.<name>) condition.

    Only matches the pattern where the exact variable name appears as the second
    argument to contains(). A contains() on a map key or a different variable yields
    no options here. Returns a tuple of string tokens (values kept as strings; the
    lint check compares against sidecar YAML values which are also strings).
    """
    val = body.get("validation")
    if not isinstance(val, list):
        return ()
    pat = re.compile(
        r"contains\(\s*\[([^\]]*)\]\s*,\s*var\." + re.escape(name) + r"\s*\)"
    )
    for entry in val:
        cond = str(entry.get("condition", ""))
        m = pat.search(cond)
        if m:
            inner = m.group(1)
            opts = []
            for tok in inner.split(","):
                tok = tok.strip()
                if tok:
                    opts.append(_strip_quotes(tok))
            return tuple(opts)
    return ()


def _canonical_value_str(v) -> str:
    """Stable, order-independent string form of any hcl2 value.
    Used for equality comparison across output value expressions (checks 8 alias + 13)."""
    if isinstance(v, dict):
        return repr(sorted((k, _canonical_value_str(w)) for k, w in v.items()))
    if isinstance(v, list):
        return repr([_canonical_value_str(item) for item in v])
    return str(v)


def parse_output_values(text: str) -> dict:
    """Return {output_name: OutputFact} for every output block in outputs.tf text."""
    if not text.strip():
        return {}
    parsed = hcl2.loads(text)
    result = {}
    for block in parsed.get("output", []):
        found = _block_label_and_body(block)
        if found is None:
            continue
        name, body = found
        if not isinstance(body, dict) or "value" not in body:
            continue
        raw = body["value"]
        fields = frozenset(raw.keys()) if isinstance(raw, dict) else frozenset()
        result[name] = OutputFact(value_str=_canonical_value_str(raw), fields=fields)
    return result


def parse_variables(text: str) -> dict:
    parsed = hcl2.loads(text)
    variables = {}
    for block in parsed.get("variable", []):
        found = _block_label_and_body(block)
        if found is None:
            continue
        name, body = found
        type_expr = _unwrap_type(body.get("type", "")) if isinstance(body, dict) else ""
        required = isinstance(body, dict) and "default" not in body
        options = _extract_options(body, name) if isinstance(body, dict) else ()
        variables[name] = VarFact(type=type_expr, required=required, options=options)
    return variables


def parse_outputs(text: str) -> set:
    if not text.strip():
        return set()
    parsed = hcl2.loads(text)
    outputs = set()
    for block in parsed.get("output", []):
        found = _block_label_and_body(block)
        if found is not None:
            outputs.add(found[0])
    return outputs


def parse_sensitive_outputs(text: str) -> set:
    if not text.strip():
        return set()
    parsed = hcl2.loads(text)
    sensitive = set()
    for block in parsed.get("output", []):
        found = _block_label_and_body(block)
        if found is None:
            continue
        name, body = found
        if isinstance(body, dict) and body.get("sensitive") is True:
            sensitive.add(name)
    return sensitive


def _git_show(framework_path, ref, rel_path):
    return subprocess.run(
        ["git", "-C", str(framework_path), "show", f"{ref}:{rel_path}"],
        capture_output=True, text=True,
    )


def introspect(framework_path, module, ref) -> ModuleFacts:
    var_path = f"modules/{module}/variables.tf"
    r = _git_show(framework_path, ref, var_path)
    if r.returncode != 0:
        raise DriftError(f"cannot read {var_path} at {ref}: {r.stderr.strip()}")
    try:
        variables = parse_variables(r.stdout)
    except Exception as e:  # hcl2/lark raise their own types; normalize to DriftError
        raise DriftError(f"failed to parse {var_path} at {ref}: {e}") from e

    # outputs.tf is optional: some modules declare no outputs.
    out_path = f"modules/{module}/outputs.tf"
    r = _git_show(framework_path, ref, out_path)
    try:
        outputs = parse_outputs(r.stdout) if r.returncode == 0 else set()
        sensitive = parse_sensitive_outputs(r.stdout) if r.returncode == 0 else set()
        output_values = parse_output_values(r.stdout) if r.returncode == 0 else {}  # NEW
    except Exception as e:
        raise DriftError(f"failed to parse {out_path} at {ref}: {e}") from e

    return ModuleFacts(variables=variables, outputs=outputs,
                       sensitive_outputs=sensitive, output_values=output_values)  # NEW field


# --- object-type dot-path resolver (check 11) -------------------------------
# Pure string analysis over a ${...}-unwrapped HCL type expression. No I/O.

def _split_top_level(s: str, sep: str) -> list:
    """Split `s` on `sep`, but only at bracket depth 0 (parens/brackets/braces)."""
    parts = []
    depth = 0
    start = 0
    for i, ch in enumerate(s):
        if ch in "([{":
            depth += 1
        elif ch in ")]}":
            depth -= 1
        elif ch == sep and depth == 0:
            parts.append(s[start:i])
            start = i + 1
    parts.append(s[start:])
    return parts


def _ctor(expr: str):
    """For a constructor 'name(inside)' return (name, inside); else (expr, None)."""
    expr = expr.strip()
    open_i = expr.find("(")
    if open_i == -1 or not expr.endswith(")"):
        return expr, None
    return expr[:open_i].strip(), expr[open_i + 1:-1]


def _unwrap_to_object(type_expr: str):
    """Strip optional()/list()/set()/map() wrappers until an object({...}) is found.
    Return the object's brace body '{...}' (braces included), or None if the type
    bottoms out at a primitive or a non-addressable constructor."""
    expr = type_expr.strip()
    while True:
        name, inside = _ctor(expr)
        if inside is None:
            return None  # primitive (string/number/bool/any) — nothing to descend
        if name == "object":
            return inside.strip()
        if name == "optional":
            # optional(T) or optional(T, default): T is the first top-level arg
            expr = _split_top_level(inside, ",")[0].strip()
            continue
        if name in ("list", "set", "map"):
            # a continuing dot-path addresses the element/value type
            expr = inside.strip()
            continue
        return None  # tuple(...) / unknown — not addressable by a field name


def _parse_object_fields(brace_body: str) -> dict:
    """Parse '{ field = T, field2 = T2, ... }' into {field: T}, balance-aware."""
    body = brace_body.strip()
    if body.startswith("{"):
        body = body[1:]
    if body.endswith("}"):
        body = body[:-1]
    fields = {}
    for part in _split_top_level(body, ","):
        part = part.strip()
        if not part:
            continue
        key, eq, val = part.partition("=")
        if not eq:
            continue
        fields[key.strip()] = val.strip()
    return fields


def resolve_path(type_expr: str, path) -> bool:
    """True iff the dotted `path` (list of segments) resolves through `type_expr`'s
    object structure. Empty path => True (fully resolved)."""
    if not path:
        return True
    brace = _unwrap_to_object(type_expr)
    if brace is None:
        return False  # a field access is required but the type is not an object
    fields = _parse_object_fields(brace)
    head, tail = path[0], path[1:]
    if head not in fields:
        return False
    return resolve_path(fields[head], tail)

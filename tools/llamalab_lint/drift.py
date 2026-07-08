"""Pure drift computation: facts in, findings out."""
from .models import Finding, ERROR, WARN, INFO, PIN, UPGRADE


def diff(sidecar, pinned, latest):
    """Return findings. `latest` is None when latest tag == pinned tag (no-op)."""
    findings = list(_pin_pass(sidecar, pinned))
    if latest is not None:
        findings += _upgrade_pass(sidecar, pinned, latest)
    return findings


def _pin_pass(sidecar, pinned):
    pinned_vars = set(pinned.variables)
    for name in sorted(sidecar.referenced_vars - pinned_vars):
        yield Finding(family="drift", check="drift.cat1", severity=ERROR, phase=PIN,
                      name=name,
                      detail=f"variable '{name}' is referenced by the sidecar but "
                             f"absent from the module at the pinned version")
    for name in sorted(sidecar.displayed_outputs - pinned.outputs):
        yield Finding(family="drift", check="drift.cat4", severity=ERROR, phase=PIN,
                      name=name,
                      detail=f"output '{name}' is displayed by the sidecar but not "
                             f"declared by the module at the pinned version")


def _upgrade_pass(sidecar, pinned, latest, new_vars_only=False):
    findings = []
    pinned_vars = set(pinned.variables)
    latest_vars = set(latest.variables)

    # cat 1: referenced var present at pin but removed at latest
    for name in sorted((sidecar.referenced_vars & pinned_vars) - latest_vars):
        findings.append(Finding(family="drift", check="drift.cat1", severity=ERROR,
                        phase=UPGRADE, name=name,
                        detail=f"variable '{name}' exists at the pinned version but was "
                               f"removed by the latest version"))

    # cat 2: var added at latest the sidecar does not handle. The unified run scopes
    # this to genuinely-new vars so it does not double-report lint check 3 (§3, §6.3);
    # standalone diff() keeps the original unscoped behaviour.
    if new_vars_only:
        cat2_names = (latest_vars - pinned_vars) - sidecar.referenced_vars
    else:
        cat2_names = latest_vars - sidecar.referenced_vars
    for name in sorted(cat2_names):
        required = latest.variables[name].required
        severity = ERROR if required else WARN
        kind = "required" if required else "optional"
        findings.append(Finding(family="drift", check="drift.cat2", severity=severity,
                        phase=UPGRADE, name=name,
                        detail=f"latest version adds {kind} variable '{name}' which the "
                               f"sidecar does not handle"))

    # cat 3: referenced var present at both refs, type changed
    for name in sorted(sidecar.referenced_vars & pinned_vars & latest_vars):
        if pinned.variables[name].type != latest.variables[name].type:
            findings.append(Finding(family="drift", check="drift.cat3", severity=WARN,
                            phase=UPGRADE, name=name,
                            detail=f"type of variable '{name}' changed between the pinned "
                                   f"and latest versions"))

    # cat 4: outputs added (INFO) and displayed-but-removed (WARN)
    for name in sorted(latest.outputs - sidecar.displayed_outputs):
        findings.append(Finding(family="drift", check="drift.cat4", severity=INFO,
                        phase=UPGRADE, name=name,
                        detail=f"latest version adds output '{name}' not shown in the summary"))
    for name in sorted((sidecar.displayed_outputs & pinned.outputs) - latest.outputs):
        findings.append(Finding(family="drift", check="drift.cat4", severity=WARN,
                        phase=UPGRADE, name=name,
                        detail=f"output '{name}' is displayed by the sidecar but removed "
                               f"by the latest version"))

    return findings

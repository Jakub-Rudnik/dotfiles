#!/usr/bin/env python3
"""Lid policy for Hyprland. Requires logind to ignore lid events (see below)."""

# Configure /etc/systemd/logind.conf.d/50-hypr-lid.conf as follows, then reboot:
# [Login]
# HandleLidSwitch=ignore
# HandleLidSwitchExternalPower=ignore
# HandleLidSwitchDocked=ignore
# Otherwise logind may suspend before Hyprland can apply this policy.

import json
import os
from pathlib import Path
import subprocess
import sys

PANEL = "eDP-1"  # Same output and mode as in hyprland.lua.
PANEL_MODE = "1920x1200"


def run(*args):
    return subprocess.run(args, check=True, capture_output=True, text=True)


def main(action):
    runtime = os.environ.get("XDG_RUNTIME_DIR")
    instance = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    if not runtime or not instance:
        raise RuntimeError("Not running inside a Hyprland session")
    marker = Path(runtime) / ("hypr-lid-" + instance)

    if action == "close":
        monitors = json.loads(run("hyprctl", "monitors", "-j").stdout)
        if any(m["name"] != PANEL and not m.get("disabled", False) for m in monitors):
            # Disabling (rather than DPMS off) moves workspaces to the other screens.
            if any(m["name"] == PANEL for m in monitors):
                run("hyprctl", "keyword", "monitor", f"{PANEL},disable")
                marker.touch(mode=0o600)
        else:
            run("systemctl", "suspend")
    elif action == "open":
        if marker.exists():
            run("hyprctl", "keyword", "monitor", f"{PANEL},{PANEL_MODE},auto,1")
            marker.unlink()
    else:
        raise ValueError("Expected close or open")


if __name__ == "__main__":
    try:
        main(sys.argv[1] if len(sys.argv) == 2 else "")
    except (OSError, ValueError, KeyError, subprocess.CalledProcessError, RuntimeError) as exc:
        print(f"lid.py: {exc}", file=sys.stderr)
        sys.exit(1)

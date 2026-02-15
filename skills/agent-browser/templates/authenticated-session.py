#!/usr/bin/env python3
"""
Template: Authenticated Session Workflow
Purpose: Login once, save state, reuse for subsequent runs
Usage: python authenticated-session.py <login-url> [state-file]

Environment variables:
  APP_USERNAME - Login username/email
  APP_PASSWORD - Login password

Two modes:
  1. Discovery mode (default): Shows form structure so you can identify refs
  2. Login mode: Performs actual login after you update the refs below

Setup steps:
  1. Run once to see form structure (discovery mode)
  2. Update refs in LOGIN FLOW section below
  3. Set APP_USERNAME and APP_PASSWORD
  4. Delete the DISCOVERY section (or flip DISCOVERY_MODE to False)
"""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path


def _run(cmd: list[str], *, capture: bool = False) -> str:
    if capture:
        out = subprocess.check_output(cmd, text=True)
        return out.strip()
    subprocess.run(cmd, check=True)
    return ""


def main(argv: list[str]) -> int:
    if not argv:
        print("Usage: python authenticated-session.py <login-url> [state-file]", file=sys.stderr)
        return 2

    login_url = argv[0]
    state_file = Path(argv[1] if len(argv) > 1 else "./auth-state.json")

    print(f"Authentication workflow: {login_url}")

    # ================================================================
    # SAVED STATE: Skip login if valid saved state exists
    # ================================================================
    if state_file.is_file():
        print(f"Loading saved state from {state_file}...")
        _run(["agent-browser", "state", "load", str(state_file)])
        _run(["agent-browser", "open", login_url])
        _run(["agent-browser", "wait", "--load", "networkidle"])

        current_url = _run(["agent-browser", "get", "url"], capture=True)
        if ("login" not in current_url) and ("signin" not in current_url):
            print("Session restored successfully")
            _run(["agent-browser", "snapshot", "-i"])
            return 0

        print("Session expired, performing fresh login...")
        state_file.unlink(missing_ok=True)

    # ================================================================
    # DISCOVERY MODE: Shows form structure (delete after setup)
    # ================================================================
    discovery_mode = True
    if discovery_mode:
        print("Opening login page...")
        _run(["agent-browser", "open", login_url])
        _run(["agent-browser", "wait", "--load", "networkidle"])

        print("")
        print("Login form structure:")
        print("---")
        _run(["agent-browser", "snapshot", "-i"])
        print("---")
        print("")
        print("Next steps:")
        print("  1. Note the refs: username=@e?, password=@e?, submit=@e?")
        print("  2. Update the LOGIN FLOW section below with your refs")
        print("  3. Set: APP_USERNAME and APP_PASSWORD")
        print("  4. Delete this DISCOVERY MODE section (or set discovery_mode = False)")
        _run(["agent-browser", "close"])
        return 0

    # ================================================================
    # LOGIN FLOW: Customize after discovery
    # ================================================================
    app_username = os.environ.get("APP_USERNAME")
    app_password = os.environ.get("APP_PASSWORD")
    if not app_username or not app_password:
        print("Error: set APP_USERNAME and APP_PASSWORD.", file=sys.stderr)
        return 2

    _run(["agent-browser", "open", login_url])
    _run(["agent-browser", "wait", "--load", "networkidle"])
    _run(["agent-browser", "snapshot", "-i"])

    # Fill credentials (update refs to match your form)
    _run(["agent-browser", "fill", "@e1", app_username])
    _run(["agent-browser", "fill", "@e2", app_password])
    _run(["agent-browser", "click", "@e3"])
    _run(["agent-browser", "wait", "--load", "networkidle"])

    final_url = _run(["agent-browser", "get", "url"], capture=True)
    if ("login" in final_url) or ("signin" in final_url):
        print("Login failed - still on login page", file=sys.stderr)
        _run(["agent-browser", "screenshot", "/tmp/login-failed.png"])
        _run(["agent-browser", "close"])
        return 1

    print(f"Saving state to {state_file}")
    _run(["agent-browser", "state", "save", str(state_file)])
    print("Login successful")
    _run(["agent-browser", "snapshot", "-i"])
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))


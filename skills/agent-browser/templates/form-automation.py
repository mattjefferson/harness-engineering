#!/usr/bin/env python3
"""
Template: Form Automation Workflow
Purpose: Fill and submit web forms with validation
Usage: python form-automation.py <form-url>

This template demonstrates the snapshot-interact-verify pattern:
1. Navigate to form
2. Snapshot to get element refs
3. Fill fields using refs
4. Submit and verify result

Customize: Update the refs (@e1, @e2, etc.) based on your form's snapshot output.
"""

from __future__ import annotations

import subprocess
import sys


def _run(cmd: list[str], *, capture: bool = False) -> str:
    if capture:
        out = subprocess.check_output(cmd, text=True)
        return out.strip()
    subprocess.run(cmd, check=True)
    return ""


def main(argv: list[str]) -> int:
    if not argv:
        print("Usage: python form-automation.py <form-url>", file=sys.stderr)
        return 2

    form_url = argv[0]
    print(f"Form automation: {form_url}")

    # Step 1: Navigate to form
    _run(["agent-browser", "open", form_url])
    _run(["agent-browser", "wait", "--load", "networkidle"])

    # Step 2: Snapshot to discover form elements
    print("")
    print("Form structure:")
    _run(["agent-browser", "snapshot", "-i"])

    # Step 3: Fill form fields (customize these refs based on snapshot output)
    #
    # Common field types:
    #   agent-browser fill @e1 "John Doe"           # Text input
    #   agent-browser fill @e2 "user@example.com"   # Email input
    #   agent-browser fill @e3 "SecureP@ss123"      # Password input
    #   agent-browser select @e4 "Option Value"     # Dropdown
    #   agent-browser check @e5                     # Checkbox
    #   agent-browser click @e6                     # Radio button
    #   agent-browser fill @e7 "Multi-line text"    # Textarea
    #   agent-browser upload @e8 /path/to/file.pdf  # File upload
    #
    # Uncomment and modify:
    # _run(["agent-browser", "fill", "@e1", "Test User"])
    # _run(["agent-browser", "fill", "@e2", "test@example.com"])
    # _run(["agent-browser", "click", "@e3"])  # Submit button
    #
    # Step 4: Wait for submission
    # _run(["agent-browser", "wait", "--load", "networkidle"])
    # _run(["agent-browser", "wait", "--url", "**/success"])  # Or wait for redirect

    # Step 5: Verify result
    print("")
    print("Result:")
    print(_run(["agent-browser", "get", "url"], capture=True))
    _run(["agent-browser", "snapshot", "-i"])

    # Optional: Capture evidence
    _run(["agent-browser", "screenshot", "/tmp/form-result.png"])
    print("Screenshot saved: /tmp/form-result.png")

    _run(["agent-browser", "close"])
    print("Done")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))


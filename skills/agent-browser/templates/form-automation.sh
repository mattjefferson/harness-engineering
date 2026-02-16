#!/bin/bash
set -euo pipefail

# Template: Form Automation Workflow
# Purpose: Fill and submit web forms with validation
# Usage: bash form-automation.sh <form-url>
#
# This template demonstrates the snapshot-interact-verify pattern:
# 1. Navigate to form
# 2. Snapshot to get element refs
# 3. Fill fields using refs
# 4. Submit and verify result
#
# Customize: Update the refs (@e1, @e2, etc.) based on your form's snapshot output.

_run() {
    "$@"
}

_capture() {
    "$@" | tr -d '\n'
}

if [[ $# -lt 1 ]]; then
    echo "Usage: bash form-automation.sh <form-url>" >&2
    exit 2
fi

form_url="$1"
echo "Form automation: ${form_url}"

# Step 1: Navigate to form
_run agent-browser open "${form_url}"
_run agent-browser wait --load networkidle

# Step 2: Snapshot to discover form elements
echo ""
echo "Form structure:"
_run agent-browser snapshot -i

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
# _run agent-browser fill @e1 "Test User"
# _run agent-browser fill @e2 "test@example.com"
# _run agent-browser click @e3  # Submit button
#
# Step 4: Wait for submission
# _run agent-browser wait --load networkidle
# _run agent-browser wait --url "**/success"  # Or wait for redirect

# Step 5: Verify result
echo ""
echo "Result:"
_capture agent-browser get url
echo ""
_run agent-browser snapshot -i

# Optional: Capture evidence
_run agent-browser screenshot /tmp/form-result.png
echo "Screenshot saved: /tmp/form-result.png"

_run agent-browser close
echo "Done"
exit 0

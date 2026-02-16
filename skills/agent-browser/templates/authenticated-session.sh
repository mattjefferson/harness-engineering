#!/bin/bash
set -euo pipefail

# Template: Authenticated Session Workflow
# Purpose: Login once, save state, reuse for subsequent runs
# Usage: bash authenticated-session.sh <login-url> [state-file]
#
# Environment variables:
#   APP_USERNAME - Login username/email
#   APP_PASSWORD - Login password
#
# Two modes:
#   1. Discovery mode (default): Shows form structure so you can identify refs
#   2. Login mode: Performs actual login after you update the refs below
#
# Setup steps:
#   1. Run once to see form structure (discovery mode)
#   2. Update refs in LOGIN FLOW section below
#   3. Set APP_USERNAME and APP_PASSWORD
#   4. Delete the DISCOVERY section (or flip discovery_mode to false)

_run() {
    "$@"
}

_capture() {
    "$@" | tr -d '\n'
}

if [[ $# -lt 1 ]]; then
    echo "Usage: bash authenticated-session.sh <login-url> [state-file]" >&2
    exit 2
fi

login_url="$1"
state_file="${2:-./auth-state.json}"

echo "Authentication workflow: ${login_url}"

# ================================================================
# SAVED STATE: Skip login if valid saved state exists
# ================================================================
if [[ -f "${state_file}" ]]; then
    echo "Loading saved state from ${state_file}..."
    _run agent-browser state load "${state_file}"
    _run agent-browser open "${login_url}"
    _run agent-browser wait --load networkidle

    current_url=$(_capture agent-browser get url)
    if [[ "${current_url}" != *"login"* ]] && [[ "${current_url}" != *"signin"* ]]; then
        echo "Session restored successfully"
        _run agent-browser snapshot -i
        exit 0
    fi

    echo "Session expired, performing fresh login..."
    rm -f "${state_file}"
fi

# ================================================================
# DISCOVERY MODE: Shows form structure (delete after setup)
# ================================================================
discovery_mode=true
if [[ "${discovery_mode}" == "true" ]]; then
    echo "Opening login page..."
    _run agent-browser open "${login_url}"
    _run agent-browser wait --load networkidle

    echo ""
    echo "Login form structure:"
    echo "---"
    _run agent-browser snapshot -i
    echo "---"
    echo ""
    echo "Next steps:"
    echo "  1. Note the refs: username=@e?, password=@e?, submit=@e?"
    echo "  2. Update the LOGIN FLOW section below with your refs"
    echo "  3. Set: APP_USERNAME and APP_PASSWORD"
    echo '  4. Delete this DISCOVERY MODE section (or set discovery_mode=false)'
    _run agent-browser close
    exit 0
fi

# ================================================================
# LOGIN FLOW: Customize after discovery
# ================================================================
app_username="${APP_USERNAME:-}"
app_password="${APP_PASSWORD:-}"
if [[ -z "${app_username}" ]] || [[ -z "${app_password}" ]]; then
    echo "Error: set APP_USERNAME and APP_PASSWORD." >&2
    exit 2
fi

_run agent-browser open "${login_url}"
_run agent-browser wait --load networkidle
_run agent-browser snapshot -i

# Fill credentials (update refs to match your form)
_run agent-browser fill @e1 "${app_username}"
_run agent-browser fill @e2 "${app_password}"
_run agent-browser click @e3
_run agent-browser wait --load networkidle

final_url=$(_capture agent-browser get url)
if [[ "${final_url}" == *"login"* ]] || [[ "${final_url}" == *"signin"* ]]; then
    echo "Login failed - still on login page" >&2
    _run agent-browser screenshot /tmp/login-failed.png
    _run agent-browser close
    exit 1
fi

echo "Saving state to ${state_file}"
_run agent-browser state save "${state_file}"
echo "Login successful"
_run agent-browser snapshot -i
exit 0

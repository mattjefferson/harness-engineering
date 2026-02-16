#!/bin/bash
set -euo pipefail

# Template: Content Capture Workflow
# Purpose: Extract content from web pages (text, screenshots, PDF)
# Usage: bash capture-workflow.sh <url> [output-dir]
#
# Outputs:
#   - page-full.png: Full page screenshot
#   - page-structure.txt: Page element structure with refs
#   - page-text.txt: All text content
#   - page.pdf: PDF version
#
# Optional: Load auth state for protected pages.

_run() {
    "$@"
}

_capture() {
    "$@" | tr -d '\n'
}

if [[ $# -lt 1 ]]; then
    echo "Usage: bash capture-workflow.sh <url> [output-dir]" >&2
    exit 2
fi

target_url="$1"
output_dir="$(cd "${2:-.}" 2>/dev/null && pwd || mkdir -p "${2:-.}" && cd "${2:-.}" && pwd)"

echo "Capturing: ${target_url}"
echo "Output dir: ${output_dir}"

# Optional: Load authentication state
# state_path="./auth-state.json"
# if [[ -f "${state_path}" ]]; then
#     echo "Loading authentication state..."
#     _run agent-browser state load "${state_path}"
# fi

_run agent-browser open "${target_url}"
_run agent-browser wait --load networkidle

title=$(_capture agent-browser get title)
url=$(_capture agent-browser get url)
echo "Title: ${title}"
echo "URL: ${url}"

full_png="${output_dir}/page-full.png"
structure_txt="${output_dir}/page-structure.txt"
text_txt="${output_dir}/page-text.txt"
page_pdf="${output_dir}/page.pdf"

_run agent-browser screenshot --full "${full_png}"
echo "Saved: ${full_png}"

agent-browser snapshot -i > "${structure_txt}"
echo "Saved: ${structure_txt}"

agent-browser get text body > "${text_txt}"
echo "Saved: ${text_txt}"

_run agent-browser pdf "${page_pdf}"
echo "Saved: ${page_pdf}"

# Optional: Extract specific elements using refs from structure
# main_content=$(_capture agent-browser get text @e5)
# echo "${main_content}" > "${output_dir}/main-content.txt"

_run agent-browser close

echo ""
echo "Capture complete:"
for f in "${output_dir}"/*; do
    echo "  - $(basename "${f}")"
done

exit 0

#!/bin/bash
set -euo pipefail

# promote-browser-evidence.sh
# Promote a minimal committed evidence set from tmp artifacts into docs artifacts.

slug=""
scenario=""
phase="resolution"
source_root="tmp/artifacts"
dest_root="docs/artifacts"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --slug)
      slug="$2"; shift 2 ;;
    --scenario)
      scenario="$2"; shift 2 ;;
    --phase)
      phase="$2"; shift 2 ;;
    --source-root)
      source_root="$2"; shift 2 ;;
    --dest-root)
      dest_root="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: promote-browser-evidence.sh --slug SLUG --scenario SCENARIO [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --slug         Required. Initiative slug."
      echo "  --scenario     Required. Scenario id."
      echo "  --phase        Optional. failure|resolution (default: resolution)."
      echo "  --source-root  Optional. Source root (default: tmp/artifacts)."
      echo "  --dest-root    Optional. Destination root (default: docs/artifacts)."
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

missing=()
[[ -z "$slug" ]] && missing+=("--slug")
[[ -z "$scenario" ]] && missing+=("--scenario")
if [[ ${#missing[@]} -gt 0 ]]; then
  echo "Error: missing required arguments: ${missing[*]}" >&2
  exit 2
fi

if [[ "$phase" != "failure" && "$phase" != "resolution" ]]; then
  echo "Error: --phase must be 'failure' or 'resolution', got '$phase'" >&2
  exit 2
fi

src_dir="${source_root}/${slug}/browser/${scenario}"
dest_dir="${dest_root}/${slug}/browser/${scenario}"
manifest_src="${src_dir}/manifest.tsv"

if [[ ! -d "$src_dir" ]]; then
  echo "Error: source scenario directory not found: ${src_dir}" >&2
  exit 1
fi

if [[ ! -f "$manifest_src" ]]; then
  echo "Error: manifest not found: ${manifest_src}" >&2
  exit 1
fi

latest_screenshot="$(ls -1 "${src_dir}/${phase}-final-"*.png 2>/dev/null | sort | tail -n 1 || true)"
if [[ -z "${latest_screenshot}" ]]; then
  echo "Error: no ${phase} final screenshot found in ${src_dir}" >&2
  exit 1
fi

mkdir -p "$dest_dir"

manifest_dest="${dest_dir}/manifest.tsv"
screenshot_dest="${dest_dir}/$(basename "$latest_screenshot")"

cp "$manifest_src" "$manifest_dest"
cp "$latest_screenshot" "$screenshot_dest"

echo "Promoted minimal evidence set:"
echo "- manifest: ${manifest_dest}"
echo "- screenshot: ${screenshot_dest}"

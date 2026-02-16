#!/bin/bash
set -euo pipefail

# record-browser-evidence.sh
# Wrap an agent-browser flow script with video recording and durable artifact output.

# --- Defaults ---
slug=""
scenario=""
phase=""
flow_script=""
output_root="tmp/artifacts"
session=""
agent_browser_args=()
keep_browser_open=false

# --- Arg parsing ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --slug)
      slug="$2"; shift 2 ;;
    --scenario)
      scenario="$2"; shift 2 ;;
    --phase)
      phase="$2"; shift 2 ;;
    --flow-script)
      flow_script="$2"; shift 2 ;;
    --output-root)
      output_root="$2"; shift 2 ;;
    --session)
      session="$2"; shift 2 ;;
    --agent-browser-arg)
      agent_browser_args+=("$2"); shift 2 ;;
    --keep-browser-open)
      keep_browser_open=true; shift ;;
    -h|--help)
      echo "Usage: record-browser-evidence.sh --slug SLUG --scenario SCENARIO --phase {failure,resolution} --flow-script PATH [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --slug                  Required. Identifier slug."
      echo "  --scenario              Required. Scenario name."
      echo "  --phase                 Required. One of: failure, resolution."
      echo "  --flow-script           Required. Path to a flow script (.py, .sh, or executable)."
      echo "  --output-root           Output root directory (default: tmp/artifacts)."
      echo "  --session               Browser session name."
      echo "  --agent-browser-arg     Extra agent-browser CLI arg. Repeatable."
      echo "  --keep-browser-open     Do not close the browser after recording."
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2; exit 2 ;;
  esac
done

# --- Validate required args ---
missing=()
[[ -z "$slug" ]]        && missing+=("--slug")
[[ -z "$scenario" ]]    && missing+=("--scenario")
[[ -z "$phase" ]]       && missing+=("--phase")
[[ -z "$flow_script" ]] && missing+=("--flow-script")

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "Error: missing required arguments: ${missing[*]}" >&2
  exit 2
fi

# --- Validate phase ---
if [[ "$phase" != "failure" && "$phase" != "resolution" ]]; then
  echo "Error: --phase must be 'failure' or 'resolution', got '$phase'" >&2
  exit 2
fi

# --- Validate flow-script ---
flow_script="$(cd "$(dirname "$flow_script")" && pwd)/$(basename "$flow_script")"
if [[ ! -f "$flow_script" ]]; then
  echo "Error: flow script not found: $flow_script" >&2
  exit 2
fi

# --- Timestamp & paths ---
timestamp="$(date -u +"%Y%m%dT%H%M%SZ")"
out_dir="${output_root}/${slug}/browser/${scenario}"
mkdir -p "$out_dir"

video_path="${out_dir}/${phase}-${timestamp}.webm"
shot_path="${out_dir}/${phase}-final-${timestamp}.png"
log_path="${out_dir}/${phase}-${timestamp}.log"
manifest_path="${out_dir}/manifest.tsv"

# --- Build agent command ---
agent_cmd=(agent-browser "${agent_browser_args[@]+"${agent_browser_args[@]}"}" ${session:+--session "$session"})

# --- Write initial log metadata ---
cat > "$log_path" <<EOF
timestamp=${timestamp}
slug=${slug}
scenario=${scenario}
phase=${phase}
flow_script=${flow_script}
session=${session:-default}
agent_browser_arg=${agent_browser_args[*]+"${agent_browser_args[*]}"}
output_dir=${out_dir}
EOF

# --- Cleanup trap ---
cleanup() {
  "${agent_cmd[@]}" record stop 2>/dev/null || true
  if [[ "$keep_browser_open" == false ]]; then
    "${agent_cmd[@]}" close 2>/dev/null || true
  fi
}
trap cleanup EXIT

# --- Recording flow ---
echo "Recording ${phase} evidence for scenario '${scenario}'"
echo "Output directory: ${out_dir}"
echo "Video target: ${video_path}"

flow_exit=0

# 1. Ensure a clean session so launch-time args apply reliably.
"${agent_cmd[@]}" record stop 2>/dev/null || true
"${agent_cmd[@]}" close 2>/dev/null || true

# 2. Start recording.
"${agent_cmd[@]}" record start "$video_path"

# 3. Run the flow script, tee output to log.
set +e
if [[ "${flow_script##*.}" == "py" ]]; then
  python3 "$flow_script" 2>&1 | tee -a "$log_path"
elif [[ "${flow_script##*.}" == "sh" ]]; then
  bash "$flow_script" 2>&1 | tee -a "$log_path"
else
  "$flow_script" 2>&1 | tee -a "$log_path"
fi
flow_exit=${PIPESTATUS[0]}
set -e

# 4. Record flow exit code in log.
echo "flow_exit=${flow_exit}" >> "$log_path"

# 5. Take screenshot (best-effort).
"${agent_cmd[@]}" screenshot "$shot_path" >> "$log_path" 2>&1 || true

# 6. Get final URL (best-effort).
final_url="$("${agent_cmd[@]}" get url 2>/dev/null)" || true
if [[ -n "${final_url:-}" ]]; then
  echo "final_url=${final_url}" >> "$log_path"
fi

# 7. Stop recording, close browser (unless --keep-browser-open).
"${agent_cmd[@]}" record stop >> "$log_path" 2>&1 || true
if [[ "$keep_browser_open" == false ]]; then
  "${agent_cmd[@]}" close >> "$log_path" 2>&1 || true
fi

# Remove the EXIT trap since we already did cleanup inline.
trap - EXIT

# --- Verify video ---
if [[ ! -s "$video_path" ]]; then
  echo "Error: recording file missing or empty: $video_path" >&2
  exit 1
fi

# --- Manifest ---
if [[ ! -f "$manifest_path" ]]; then
  printf "timestamp\tphase\tvideo\tscreenshot\tflow_exit\tflow_script\n" > "$manifest_path"
fi
printf "%s\t%s\t%s\t%s\t%s\t%s\n" \
  "$timestamp" "$phase" "$video_path" "$shot_path" "$flow_exit" "$flow_script" \
  >> "$manifest_path"

# --- Summary ---
echo "Saved video: ${video_path}"
echo "Saved screenshot: ${shot_path}"
echo "Saved log: ${log_path}"
echo "Updated manifest: ${manifest_path}"

# --- Exit logic ---
if [[ "$phase" == "resolution" && "$flow_exit" -ne 0 ]]; then
  echo "Error: resolution capture flow exited non-zero (${flow_exit})." >&2
  exit "$flow_exit"
fi

if [[ "$phase" == "failure" && "$flow_exit" -ne 0 ]]; then
  echo "Note: failure flow exited non-zero (${flow_exit}), which is allowed." >&2
fi

exit 0

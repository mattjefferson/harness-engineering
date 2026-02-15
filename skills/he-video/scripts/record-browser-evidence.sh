#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  record-browser-evidence.sh \
    --slug <slug> \
    --scenario <scenario-id> \
    --phase <failure|resolution> \
    --flow-script <path> \
    [--output-root <dir>] \
    [--session <session-name>] \
    [--keep-browser-open]

Description:
  Wraps an agent-browser flow script with video recording and durable artifact output.

Notes:
  - The flow script must NOT call "agent-browser record start/stop".
  - For phase=resolution, a non-zero flow exit code fails this wrapper.
  - For phase=failure, non-zero flow exit is allowed and logged.
EOF
}

SLUG=""
SCENARIO=""
PHASE=""
FLOW_SCRIPT=""
OUTPUT_ROOT="docs/artifacts"
SESSION=""
KEEP_BROWSER_OPEN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --slug)
      SLUG="${2:-}"
      shift 2
      ;;
    --scenario)
      SCENARIO="${2:-}"
      shift 2
      ;;
    --phase)
      PHASE="${2:-}"
      shift 2
      ;;
    --flow-script)
      FLOW_SCRIPT="${2:-}"
      shift 2
      ;;
    --output-root)
      OUTPUT_ROOT="${2:-}"
      shift 2
      ;;
    --session)
      SESSION="${2:-}"
      shift 2
      ;;
    --keep-browser-open)
      KEEP_BROWSER_OPEN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$SLUG" || -z "$SCENARIO" || -z "$PHASE" || -z "$FLOW_SCRIPT" ]]; then
  echo "Error: --slug, --scenario, --phase, and --flow-script are required." >&2
  usage >&2
  exit 2
fi

if [[ "$PHASE" != "failure" && "$PHASE" != "resolution" ]]; then
  echo "Error: --phase must be 'failure' or 'resolution'." >&2
  exit 2
fi

if [[ ! -f "$FLOW_SCRIPT" ]]; then
  echo "Error: flow script not found: $FLOW_SCRIPT" >&2
  exit 2
fi

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="${OUTPUT_ROOT}/${SLUG}/browser/${SCENARIO}"
mkdir -p "$OUT_DIR"

VIDEO_PATH="${OUT_DIR}/${PHASE}-${TIMESTAMP}.webm"
SHOT_PATH="${OUT_DIR}/${PHASE}-final-${TIMESTAMP}.png"
LOG_PATH="${OUT_DIR}/${PHASE}-${TIMESTAMP}.log"
MANIFEST_PATH="${OUT_DIR}/manifest.tsv"

agent_cmd=(agent-browser)
if [[ -n "$SESSION" ]]; then
  agent_cmd+=(--session "$SESSION")
fi

cleanup() {
  "${agent_cmd[@]}" record stop >/dev/null 2>&1 || true
  if [[ "$KEEP_BROWSER_OPEN" -ne 1 ]]; then
    "${agent_cmd[@]}" close >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

{
  echo "timestamp=${TIMESTAMP}"
  echo "slug=${SLUG}"
  echo "scenario=${SCENARIO}"
  echo "phase=${PHASE}"
  echo "flow_script=${FLOW_SCRIPT}"
  echo "session=${SESSION:-default}"
  echo "output_dir=${OUT_DIR}"
} > "$LOG_PATH"

echo "Recording ${PHASE} evidence for scenario '${SCENARIO}'"
echo "Output directory: ${OUT_DIR}"
echo "Video target: ${VIDEO_PATH}"

"${agent_cmd[@]}" record start "$VIDEO_PATH"

set +e
bash "$FLOW_SCRIPT" 2>&1 | tee -a "$LOG_PATH"
FLOW_EXIT="${PIPESTATUS[0]}"
set -e

echo "flow_exit=${FLOW_EXIT}" >> "$LOG_PATH"

"${agent_cmd[@]}" screenshot "$SHOT_PATH" >> "$LOG_PATH" 2>&1 || true
FINAL_URL="$("${agent_cmd[@]}" get url 2>>"$LOG_PATH" || true)"
if [[ -n "$FINAL_URL" ]]; then
  echo "final_url=${FINAL_URL}" >> "$LOG_PATH"
fi

"${agent_cmd[@]}" record stop >> "$LOG_PATH" 2>&1 || true
if [[ "$KEEP_BROWSER_OPEN" -ne 1 ]]; then
  "${agent_cmd[@]}" close >> "$LOG_PATH" 2>&1 || true
fi
trap - EXIT

if [[ ! -s "$VIDEO_PATH" ]]; then
  echo "Error: recording file missing or empty: $VIDEO_PATH" >&2
  exit 1
fi

if [[ ! -f "$MANIFEST_PATH" ]]; then
  printf "timestamp\tphase\tvideo\tscreenshot\tflow_exit\tflow_script\n" > "$MANIFEST_PATH"
fi

printf "%s\t%s\t%s\t%s\t%s\t%s\n" \
  "$TIMESTAMP" \
  "$PHASE" \
  "$VIDEO_PATH" \
  "$SHOT_PATH" \
  "$FLOW_EXIT" \
  "$FLOW_SCRIPT" >> "$MANIFEST_PATH"

echo "Saved video: $VIDEO_PATH"
echo "Saved screenshot: $SHOT_PATH"
echo "Saved log: $LOG_PATH"
echo "Updated manifest: $MANIFEST_PATH"

if [[ "$PHASE" == "resolution" && "$FLOW_EXIT" -ne 0 ]]; then
  echo "Error: resolution capture flow exited non-zero ($FLOW_EXIT)." >&2
  exit "$FLOW_EXIT"
fi

if [[ "$PHASE" == "failure" && "$FLOW_EXIT" -ne 0 ]]; then
  echo "Note: failure flow exited non-zero ($FLOW_EXIT), which is allowed." >&2
fi


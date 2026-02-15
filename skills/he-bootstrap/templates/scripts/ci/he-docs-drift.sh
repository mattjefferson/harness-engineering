#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

CONFIG_FILE="${HARNESS_DOCS_CONFIG:-scripts/ci/he-docs-config.sh}"
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
else
  echo "Error: he-docs-drift missing config '$CONFIG_FILE'." >&2
  echo "Fix: create it (bootstrap should do this) or set HARNESS_DOCS_CONFIG to a valid path." >&2
  exit 2
fi

fail() {
  echo "Error: $*" >&2
  exit 1
}

base_ref="${GITHUB_BASE_REF:-}"
head_ref="${GITHUB_HEAD_REF:-}"

# Determine diff range. In GitHub Actions PRs, origin/<base> exists after checkout with fetch-depth: 0.
diff_range=""
if [[ -n "$base_ref" ]]; then
  diff_range="origin/$base_ref...HEAD"
else
  if git rev-parse -q --verify HEAD~1 >/dev/null 2>&1; then
    diff_range="HEAD~1...HEAD"
  else
    diff_range=""
  fi
fi

if [[ -n "$diff_range" ]]; then
  changed_files="$(git diff --name-only $diff_range || true)"
else
  # Initial commit case (no HEAD~1): diff against empty tree.
  changed_files="$(git diff-tree --no-commit-id --name-only -r HEAD || true)"
fi

echo "he-docs-drift: starting (config: $CONFIG_FILE)" >&2
echo "Repro: bash scripts/ci/he-docs-drift.sh" >&2
if [[ -n "$base_ref" ]]; then
  echo "PR context: base_ref='$base_ref' head_ref='${head_ref:-}' diff='$diff_range'" >&2
else
  echo "Local context: diff='$diff_range'" >&2
fi

if [[ -z "$changed_files" ]]; then
  echo "he-docs-drift: no changes detected"
  exit 0
fi

changed_docs_set="$(printf "%s\n" "$changed_files" | grep -E '^docs/' || true)"

missing=0
for rule in "${HARNESS_DRIFT_RULES[@]}"; do
  regex="${rule%%::*}"
  doc="${rule##*::}"

  if printf "%s\n" "$changed_files" | grep -Eq -- "$regex"; then
    matches="$(printf "%s\n" "$changed_files" | grep -E -- "$regex" | head -n 10 || true)"
    if ! printf "%s\n" "$changed_docs_set" | grep -Fqx -- "$doc"; then
      echo "::error file=${doc},title=Docs drift gate::Missing required doc update '${doc}' when files match /${regex}/ (see job logs for matching files)."
      echo "Missing doc update: '$doc' should change when files match /$regex/." >&2
      echo "Matching files (up to 10):" >&2
      echo "$matches" | sed 's/^/- /' >&2
      echo "Fix: update '$doc' in this PR, or edit HARNESS_DRIFT_RULES in '$CONFIG_FILE' if this mapping is wrong." >&2
      missing=1
    fi
  fi
done

if [[ "$missing" -eq 1 ]]; then
  fail "docs drift gate failed (see missing doc updates above)"
fi

echo "he-docs-drift: OK"

#!/usr/bin/env bash
set -euo pipefail

# Simple POC script: read README.md and print its title

REPO_DIR="$GITHUB_WORKSPACE"
REPORTS_DIR="${REPO_DIR}/reports"

DATE_STR="$(date +%F)"
REPORT_FILE="${REPORTS_DIR}/poc-review-${DATE_STR}.md"

mkdir -p "$REPORTS_DIR"

echo "[poc] Running simple README title extraction"

# Ensure README exists
if [ ! -f "${REPO_DIR}/README.md" ]; then
  echo "[poc] ERROR: README.md not found!"
  exit 1
fi

# Extract first Markdown H1 title: "# Something"
README_TITLE="$(grep '^# ' "${REPO_DIR}/README.md" | head -n 1 | sed 's/^# //')"

if [ -z "$README_TITLE" ]; then
  README_TITLE="(No H1 title found in README.md)"
fi

echo "[poc] README title: $README_TITLE"

# Write the report
{
  echo "# Proof of Concept Report"
  echo
  echo "Generated on: ${DATE_STR}"
  echo
  echo "## README Title"
  echo
  echo "${README_TITLE}"
  echo
} > "${REPORT_FILE}"

echo "[poc] POC report written to: ${REPORT_FILE}"

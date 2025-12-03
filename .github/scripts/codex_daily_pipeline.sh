#!/usr/bin/env bash
set -euo pipefail

echo "[codex-poc] Starting Codex README title check"

REPO_DIR="${GITHUB_WORKSPACE:-$(pwd)}"
README_PATH="${REPO_DIR}/README.md"

# Ensure Codex CLI is installed
if ! command -v codex >/dev/null 2>&1; then
  echo "[codex-poc] ERROR: The 'codex' CLI is not installed or not in PATH."
  echo "[codex-poc] Make sure your GitHub Action installs it via npm."
  exit 1
fi

# Ensure README exists
if [ ! -f "$README_PATH" ]; then
  echo "[codex-poc] ERROR: README.md not found at ${README_PATH}"
  exit 1
fi

README_CONTENT="$(cat "$README_PATH")"

echo "[codex-poc] Calling Codex to extract title and capitalization info..."

CODEX_RESPONSE="$(
  printf '%s\n\n%s\n\n%s\n\n%s\n' \
    "You are an assistant analyzing a README file." \
    "README CONTENT:" \
    "${README_CONTENT}" \
    "Tasks:
1. Extract the main README title (the H1 heading beginning with '# ').
2. Tell me whether *all letters in that title* are capitalized (YES or NO).
3. Output only:
   Title: <title>
   All Caps: <YES or NO>" \
  | codex ask
)"

echo "[codex-poc] Codex Result:"
echo "--------------------------------"
echo "${CODEX_RESPONSE}"
echo "--------------------------------"

#!/usr/bin/env bash
# codex_daily_pipeline.sh
# Coordinated daily pipeline for Alloy Recon Agent.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="${LOG_DIR:-"$ROOT_DIR/.logs"}"
TIMESTAMP="$(date -u +"%Y-%m-%dT%H-%M-%SZ")"
LOG_FILE="$LOG_DIR/codex_daily_pipeline_$TIMESTAMP.log"

mkdir -p "$LOG_DIR"

declare -a PIPELINE_STEPS=()

log() {
  echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] $*" | tee -a "$LOG_FILE"
}

run_step() {
  local step_name="$1"
  shift
  log "Starting: $step_name"
  if "$@" 2>&1 | tee -a "$LOG_FILE"; then
    log "Completed: $step_name"
  else
    log "Failed: $step_name"
    exit 1
  fi
}

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log "Missing required command: $cmd"
    exit 1
  fi
}

register_step() {
  PIPELINE_STEPS+=("$1")
}

setup_environment() {
  log "Ensuring pnpm is available"
  require_command pnpm

  if [[ -f "$ROOT_DIR/.env" ]]; then
    log "Loading environment variables from .env"
    # shellcheck disable=SC2046
    export $(grep -v "^#" "$ROOT_DIR/.env" | xargs -d '\n')
  fi
}

install_dependencies() {
  if [[ -f "$ROOT_DIR/pnpm-lock.yaml" || -f "$ROOT_DIR/package.json" ]]; then
    pnpm install --frozen-lockfile || pnpm install
  else
    log "No package manifest found; skipping install"
  fi
}

run_lint() {
  if pnpm -s run --if-present lint >/dev/null 2>&1; then
    pnpm -s run lint
  else
    log "No lint script defined; skipping"
  fi
}

run_tests() {
  if pnpm -s run --if-present test >/dev/null 2>&1; then
    pnpm -s run test
  else
    log "No test script defined; skipping"
  fi
}

run_build() {
  if pnpm -s run --if-present build >/dev/null 2>&1; then
    pnpm -s run build
  else
    log "No build script defined; skipping"
  fi
}

register_step setup_environment
register_step install_dependencies
register_step run_lint
register_step run_tests
register_step run_build

log "Starting codex daily pipeline"
for step in "${PIPELINE_STEPS[@]}"; do
  run_step "$step" "$step"
done
log "Pipeline finished successfully"

#!/usr/bin/env bash
set -uo pipefail

run_report_only_scan() {
  local name="$1"
  shift

  echo "::group::${name}"
  "$@"
  local status=$?
  echo "::endgroup::"

  echo "${name} exited with status ${status}; leaving job green because Snyk is report-only."
  return 0
}

if ! command -v snyk >/dev/null 2>&1; then
  echo "Snyk CLI was not installed; skipping report-only Snyk scans."
  exit 0
fi

run_report_only_scan \
  "Broad Snyk scan" \
  snyk test --all-projects --severity-threshold=high

run_report_only_scan \
  "Android release runtime Snyk scan" \
  snyk test \
    --file=android/build.gradle.kts \
    --gradle-sub-project=app \
    --configuration-matching='^prodReleaseRuntimeClasspath$' \
    --severity-threshold=high

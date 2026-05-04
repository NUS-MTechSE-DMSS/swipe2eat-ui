#!/usr/bin/env bash
set -euo pipefail

environment_name="${1:?environment name is required}"
output_path="${2:-$RUNNER_TEMP/dart-defines.json}"
default_file="config/env/${environment_name}.json"

if [[ -n "${DART_DEFINES_JSON_BASE64:-}" ]]; then
  printf '%s' "${DART_DEFINES_JSON_BASE64}" | base64 --decode > "${output_path}"
elif [[ -n "${DART_DEFINES_JSON:-}" ]]; then
  printf '%s' "${DART_DEFINES_JSON}" > "${output_path}"
elif [[ -f "${default_file}" ]]; then
  cp "${default_file}" "${output_path}"
else
  echo "No dart defines were provided and ${default_file} does not exist." >&2
  exit 1
fi

echo "${output_path}"

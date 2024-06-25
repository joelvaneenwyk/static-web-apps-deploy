#!/usr/bin/env bash

set -eax

echo "##[cmd] entrypoint.sh $*"
export HUGO_VERSION="${HUGO_VERSION:-0.127.0}"
export INPUT_ACTION="${INPUT_ACTION:-${1:-build}}"

if [[ "${INPUT_ACTION:-}" = "${1:-}" ]]; then
  shift
fi

export SWA_DIR="${SWA_DIR:-/bin/staticsites}"
if [ ! -e "${SWA_DIR:-}/StaticSitesClient" ]; then
  export SWA_DIR=./.bin/
fi

if [ ! -e "${SWA_DIR:-}/StaticSitesClient" ]; then
  echo "##[error] Could not find StaticSitesClients"
  exit 1
fi

if [ -f "${SWA:-}" ]; then
  cd /bin/staticsites/ || true

  if [[ "${1:-}" == sh* ]] || [[ "${1:-}" == bash* ]]; then
    ARGS=$*
    echo "No action specified, passing all arguments to shell directly."
  else
    ARGS=("${SWA:-}" "${INPUT_ACTION}" "$@")
  fi

  echo "##[cmd] ${ARGS[*]}"
  "${ARGS[@]}"
fi

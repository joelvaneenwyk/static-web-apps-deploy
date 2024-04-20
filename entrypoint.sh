#!/usr/bin/env bash
cd /bin/staticsites/ || true

export HUGO_VERSION="${HUGO_VERSION:-0.122.0}"

echo "##[cmd] entrypoint.sh $*"

if [[ -z "${INPUT_ACTION:-}" ]] && [[ -z "$*" ]]; then
  echo "##[cmd] StaticSitesClient build $*"
  ./StaticSitesClient build "$@"
elif [[ "${1:-}" == sh* ]]; then
  echo "No action specified, launching shell."
  echo "##[cmd] $*"
  "$@"
else
  echo "##[cmd] StaticSitesClient $*"
  ./StaticSitesClient "$@"
fi

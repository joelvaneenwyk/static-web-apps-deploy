#!/usr/bin/env sh
cd /bin/staticsites/ || true

export HUGO_VERSION="${HUGO_VERSION:-0.122.0}"

if [ -z "${INPUT_ACTION}" ] && [ -z "$*" ]; then
  echo "No action specified, defaulting to build"
  export INPUT_ACTION="build"
  ./StaticSitesClient "${INPUT_ACTION}"
else
  ./StaticSitesClient "$@"
fi

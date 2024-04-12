#!/bin/sh -l
# cspell:ignore StaticSites
cd /bin/staticsites/ || true
export HUGO_VERSION=0.125.0
./StaticSitesClient "${INPUT_ACTION:-$@}"

#!/bin/sh -l
# cspell:ignore StaticSites
cd /bin/staticsites/ || true
./StaticSitesClient "${INPUT_ACTION:-$@}"

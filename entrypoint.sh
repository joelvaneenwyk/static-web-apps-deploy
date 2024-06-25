#!/usr/bin/env bash
#
# StaticSitesClient 1.0.0
# Copyright (C) 2024 StaticSitesClient
#
# Usage: StaticSitesClient [options] [command]
#
#   run        (Default Verb)
#   upload     Uploads App and Api artifacts.
#   close      Submits PR close message.
#   help       Display more information on a specific command.
#   version    Display version information.
#
# Options:
#
#  --verbose                       (Default: false) Enables verbose logging
#  --deploymentaction              (Default: ) Specifies the action to run
#  --workdir                       (Default: ) Working directory of the repository
#  --buildTimeoutInMinutes         (Default: ) Time limit of oryx build in minutes
#  --app                           (Default: ) Directory of app source code
#  --api                           (Default: ) Directory of api source code
#  --dataApi                       (Default: ) Directory of data api configuration files
#  --routesLocation                (Default: ) Path to the routes file
#  --configFileLocation            (Default: ) Path to the staticwebapp.config.json file
#  --outputLocation                (Default: ) Directory of built application artifacts
#  --appArtifactLocation           (Default: ) Directory of built application artifacts
#  --event                         (Default: ) Filepath of the event json
#  --apiToken                      (Default: ) ApiToken
#  --repoToken                     (Default: ) RepoToken
#  --appBuildCommand               (Default: ) App Build Command
#  --apiBuildCommand               (Default: ) Api Build Command
#  --repositoryUrl                 (Default: ) Repository Url
#  --deploymentEnvironment         (Default: ) Deployment Environment
#  --branch                        (Default: ) Branch
#  --deploymentProvider            (Default: ) Deployment provider
#  --skipAppBuild                  (Default: false) Skips Oryx build for app folder
#  --skipApiBuild                  (Default: false) Skips Oryx build for api folder
#  --skipDeployOnMissingSecrets    (Default: false) Skips deployment if api token isn't specified.
#  --isStaticExport                (Default: false) Repository uses Static Export of Site
#  --pullRequestTitle              Pull request title for staging sites.
#  --headBranch                    Head branch name for staging sites.
#  --productionBranch              Production branch. When specified, deployments from other branches will be staging environments.
#  --help                          Display this help screen.
#  --version                       Display version information.
#

set -eax -o pipefail

echo "##[cmd] $(realpath "$0" || readlink -f "$0" || $0) $*"
for a in "$@"; do
  printf "%s" "$a";
done

export HUGO_VERSION="${HUGO_VERSION:-0.127.0}"
export INPUT_ACTION="${INPUT_ACTION:-${1:-build}}"
export BUILD_COMMAND_OVERRIDE="${1:-}"

export SWA_DIR="${SWA_DIR:-/bin/staticsites}"
if [ ! -e "${SWA_DIR:-}/StaticSitesClient" ]; then
  export SWA_DIR=./.bin/
fi
export SWA="${SWA_DIR}/StaticSitesClient"

ARGS=()
if [[ -n "$*" ]] || [[ X${BUILD_COMMAND_OVERRIDE:-} == Xsh* ]] || [[ X${BUILD_COMMAND_OVERRIDE:-} == Xbash* ]]; then
  echo "No action specified, passing all arguments to shell directly."
  ARGS+=("$@")
else
  if [[ "${INPUT_ACTION:-}" = "${BUILD_COMMAND_OVERRIDE:-}" ]]; then
    shift
  fi
  ARGS+=("${SWA}" "${INPUT_ACTION}")
  if [[ -n "$*" ]]; then
    ARGS+=("$@")
  fi
fi

if [ ! -f "${SWA}" ]; then
  echo "[error] Could not find 'StaticSitesClients' executable."
  exit 80
fi

cd "${SWA_DIR}" || true
echo "##[cmd] ${ARGS[*]}"
"${ARGS[@]}"

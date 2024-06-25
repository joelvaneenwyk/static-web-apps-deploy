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
#  --api                           (Default: ) Directory of api source code
#  --apiBuildCommand               (Default: ) Api Build Command
#  --apiToken                      (Default: ) ApiToken
#  --app                           (Default: ) Directory of app source code
#  --appArtifactLocation           (Default: ) Directory of built application artifacts
#  --appBuildCommand               (Default: ) App Build Command
#  --branch                        (Default: ) Branch
#  --buildTimeoutInMinutes         (Default: ) Time limit of oryx build in minutes
#  --configFileLocation            (Default: ) Path to the staticwebapp.config.json file
#  --dataApi                       (Default: ) Directory of data api configuration files
#  --deploymentaction              (Default: ) Specifies the action to run
#  --deploymentEnvironment         (Default: ) Deployment Environment
#  --deploymentProvider            (Default: ) Deployment provider
#  --event                         (Default: ) Filepath of the event json
#  --headBranch                    Head branch name for staging sites.
#  --help                          Display this help screen.
#  --isStaticExport                (Default: false) Repository uses Static Export of Site
#  --outputLocation                (Default: ) Directory of built application artifacts
#  --productionBranch              Production branch. When specified, deployments from other branches will be staging environments.
#  --pullRequestTitle              Pull request title for staging sites.
#  --repositoryUrl                 (Default: ) Repository Url
#  --repoToken                     (Default: ) RepoToken
#  --routesLocation                (Default: ) Path to the routes file
#  --skipApiBuild                  (Default: false) Skips Oryx build for api folder
#  --skipAppBuild                  (Default: false) Skips Oryx build for app folder
#  --skipDeployOnMissingSecrets    (Default: false) Skips deployment if api token isn't specified.
#  --verbose                       (Default: false) Enables verbose logging
#  --version                       Display version information.
#  --workdir                       (Default: ) Working directory of the repository
#

set -eax -o pipefail

echo "##[cmd] $(realpath "$0" || readlink -f "$0" || $0) $*"
for argument in "$@"; do
  printf "%s" "$argument"
done

export SWA_DIR="${SWA_DIR:-/bin/staticsites}"
if [ ! -e "${SWA_DIR:-}/StaticSitesClient" ]; then
  export SWA_DIR=./.bin/
fi
export SWA="${SWA_DIR}/StaticSitesClient"

export HUGO_VERSION="${HUGO_VERSION:-0.127.0}"
export BUILD_COMMAND_OVERRIDE="${1:-}"
export ACTION=""

ARGS=()
COMMANDS=(run upload close help version)
IS_OVERRIDE=0

for argument in "$@"; do
  if [ ${#ARGS[@]} -eq 0 ]; then
    if [[ X${argument:-} == Xsh* ]] || [[ X${argument:-} == Xbash* ]]; then
      echo "No action specified, passing all arguments to shell directly."
      IS_OVERRIDE=1
    else
      ARGS+=("${SWA}")
    fi
  fi

  ARGS+=("${argument}")

  if [[ " ${COMMANDS[*]} " =~ [[:space:]]${argument}[[:space:]] ]]; then
    export ACTION="${argument}"
  fi
done

if [[ "$IS_OVERRIDE" == "0" ]] && [[ -z "$ACTION" ]]; then
  export ACTION="run"
  ARGS+=("${ACTION}")
  echo "[WARNING] No action specified so appended default 'run' action."
fi

if [[ "$IS_OVERRIDE" == "0" ]] && [[ ! "$ACTION" = "version" ]] && [[ ! " ${ARGS[*]} " =~ [[:space:]]--verbose[[:space:]] ]]; then
  ARGS+=(--verbose)
fi

if [ ! -f "${SWA}" ]; then
  echo "[error] Could not find 'StaticSitesClients' executable."
  exit 80
fi

cd "${SWA_DIR}" || true
echo "##[cmd] ${ARGS[*]}"
"${ARGS[@]}"

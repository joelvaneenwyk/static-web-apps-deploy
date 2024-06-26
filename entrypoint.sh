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

function run_command() {
  echo "##[cmd] $(realpath "$0" || readlink -f "$0" || $0) $*"

  local SUPPORTED_COMMANDS=(run upload close help version)

  local SWA_APP=StaticSitesClient
  local SWA_DIR="${SWA_DIR:-./.bin/}"
  if [ ! -e "${SWA_DIR}/${SWA_APP}" ]; then
    SWA_DIR="/bin/staticsites"
  fi
  local SWA="${SWA_DIR}/${SWA_APP}"

  local ARG_PASSTHROUGH=0
  local ARG_FOUND_APP=0
  local INPUT_ARGS=("$@")
  local OUTPUT_ARGS=()
  local OUTPUT_ACTION=""
  for argument in "${INPUT_ARGS[@]}"; do
    if [ ${#OUTPUT_ARGS[@]} -eq 0 ]; then
      if [[ X${argument:-} == Xsh* ]] || [[ X${argument:-} == Xbash* ]]; then
        echo "No action specified, passing all arguments to shell directly."
        ARG_PASSTHROUGH=1
      fi
    fi

    OUTPUT_ARGS+=("${argument}")

    if [[ ${SWA_APP} == *${argument}* ]]; then
      ARG_FOUND_APP=1
    elif [[ " ${SUPPORTED_COMMANDS[*]} " =~ [[:space:]]${argument}[[:space:]] ]]; then
      OUTPUT_ACTION="${argument}"
    fi
  done

  if [ $ARG_FOUND_APP == 0 ]; then
    OUTPUT_ARGS=("${SWA}" "${OUTPUT_ARGS[@]}")
  fi

  if [[ "$ARG_PASSTHROUGH" == "0" ]] && [[ -z "$OUTPUT_ACTION" ]]; then
    OUTPUT_ACTION="run"
    OUTPUT_ARGS+=("${OUTPUT_ACTION}")
    echo "[WARNING] No action specified so appended default 'run' action."
  fi

  if [[ "$ARG_PASSTHROUGH" == "0" ]] && [[ ! "$OUTPUT_ACTION" = "version" ]] && [[ ! " ${OUTPUT_ARGS[*]} " =~ [[:space:]]--verbose[[:space:]] ]]; then
    OUTPUT_ARGS+=(--verbose)
  fi

  cd "${SWA_DIR}" &>/dev/null || true

  if [[ "$ARG_PASSTHROUGH" == "0" ]] && [ ! -f "${SWA}" ]; then
    echo "[error] Skipped command '${OUTPUT_ARGS[*]}' due to missing '${SWA_APP}' executable."
    return 80
  fi

  echo "##[cmd] ${OUTPUT_ARGS[*]}"
  "${OUTPUT_ARGS[@]}"
}

set -ea -o pipefail
export HUGO_VERSION="${HUGO_VERSION:-0.127.0}"
run_command "$@"

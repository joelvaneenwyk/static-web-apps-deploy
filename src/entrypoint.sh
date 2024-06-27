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
  set -ea -o pipefail

  if [ -n "${DEBUG:-}" ]; then
    set -x
  fi

  echo "##[cmd] $(realpath "$0" || readlink -f "$0" || $0) $*"

  local swa_supported_commands=(run upload close help version)
  local swa_app_name=StaticSitesClient

  local arg_use_shell_passthrough=0
  local arg_found_swa_app=0
  local input_arguments=("$@")
  local output_arguments=()
  local output_action=""

  for argument in "${input_arguments[@]}"; do
    if [ ${#output_arguments[@]} -eq 0 ] && [[ X${argument:-} == Xsh* ]] || [[ X${argument:-} == Xbash* ]]; then
      arg_use_shell_passthrough=1
    fi

    if [ -n "${argument}" ]; then
      output_arguments+=("${argument}")

      if [[ X${argument} == *X${swa_app_name}* ]]; then
        arg_found_swa_app=1
      fi

      if [[ " ${swa_supported_commands[*]} " =~ [[:space:]]${argument}[[:space:]] ]]; then
        output_action="${argument}"
      fi
    fi
  done

  if [ "$(pwd)" = "/" ]; then
    cd "${WORKSPACE_DOCKER_PATH:-}" ||
      cd "${SWA_DIR:-}" ||
      cd /admin/ ||
      cd /root/build/ ||
      cd /workspace/ ||
      cd /github/workspace/ ||
      cd /bin/staticsites/ || true
  fi

  local swa_root_path="${SWA_DIR:-./.bin/}"
  if [ ! -e "${swa_root_path}/${swa_app_name}" ]; then
    swa_root_path="/bin/staticsites"
  fi
  if [ ! -d "${swa_root_path}" ]; then
    swa_root_path="$(pwd)"
  fi

  export PATH="${swa_root_path}:/bin/staticsites:~/.local/share/fnm/:/admin/${PATH+:$PATH}"

  if [[ -z "$output_action" ]] && [[ $arg_use_shell_passthrough == 0 ]]; then
    output_action="run"
    output_arguments+=("${output_action}")
    echo "[WARNING] No action specified so appended default 'run' action."
  fi

  # The argument being lower-case as '--deploymentaction' is intentional
  [[ "$output_action" == "close" ]] && output_deployment_action="close" || output_deployment_action="upload"
  if [[ ! " ${output_arguments[*]} " =~ [[:space:]]--deploymentaction[[:space:]] ]]; then
    output_arguments+=(--deploymentaction "$output_deployment_action")
    output_arguments+=(--skipDeployOnMissingSecrets)
    output_arguments+=(--skipAppBuild)
  fi

  if [[ ! " ${output_arguments[*]} " =~ [[:space:]]--verbose[[:space:]] ]] && [[ $arg_use_shell_passthrough == 0 ]] && [[ ! "$output_action" = "version" ]]; then
    output_arguments+=(--verbose)
    echo "[INFO] Enabled verbose logging."
  fi

  local swa_app_path
  if ! swa_app_path="$(command -v "${swa_app_name}")"; then
    swa_app_path="${swa_root_path}/${swa_app_name}"
  fi

  if [[ $arg_use_shell_passthrough == 1 ]]; then
    echo "No recognized action specified, so passed all arguments to shell directly: '${output_arguments[*]}'"
  elif [[ $arg_found_swa_app == 1 ]]; then
    printf "[INFO] Found '%s' executable. Skipped prepending executable to argument list.\n" "${swa_app_path}"
  else
    output_arguments=("${swa_app_path}" "${output_arguments[@]}")
    printf "[INFO] Prepended '%s' executable to command list.\n" "${swa_app_path}"
  fi

  current_dir="$(pwd)"
  if git_version="$(git --version 2>/dev/null)"; then
    echo "[INFO] Using git version: ${git_version}"

    if git config --global --add safe.directory "${current_dir}" 2>/dev/null; then
      echo "[INFO] Added '${current_dir}' to git 'safe.directory' global config."
    fi
  fi

  echo "##[group] Environment Stats"
  echo "cwd: $(pwd)"
  echo "npm: $(command -v npm 2>/dev/null)"
  echo "node: $(command -v node 2>/dev/null)"
  echo "hugo: $(command -v hugo 2>/dev/null)"
  echo "fnm: $(command -v fnm 2>/dev/null)"
  echo "##[endgroup]"

  local result=0
  echo "##[cmd] ${output_arguments[*]}"
  if [[ $arg_use_shell_passthrough == 0 ]] && [ ! -f "${swa_app_path}" ]; then
    echo "[error] Skipped command due to missing '${swa_app_name}' executable."
    result=80
  else
    echo "{{BEGIN}} Command Output"
    echo "---------------------------------------"
    local _build_dir="${current_dir}/.build"
    mkdir -p ./.build || true
    if "${output_arguments[@]}" | tee -a "./.build/static-sites-$(date +%s).log"; then
      :
    else
      result=$?
    fi
    echo "---------------------------------------"
    echo "{{END}} Command Output"

    if [ $result -eq 0 ]; then
      echo "[INFO] Successfully completed 'static-web-apps-deploy' process."
    else
      echo "[ERROR] Failed to complete 'static-web-apps-deploy' process. Error code: ${result}"
    fi
  fi
  return $result
}

export HUGO_VERSION="${HUGO_VERSION:-0.127.0}"

if _fnm_env=$(fnm env 2>/dev/null); then
  eval "$_fnm_env"
fi

run_command "$@"

#!/usr/bin/env bash

function write_env() {
  set -eax -o pipefail

  echo "TA_USERNAME=$RAW_GITHUB_ACTOR"
  echo "TA_PASSWORD=$RAW_INPUTS_REPO_TOKEN"
  echo "TA_TOKEN=$RAW_INPUTS_REPO_TOKEN"

  local RAW_GITHUB_REPOSITORY="${RAW_GITHUB_REPOSITORY:-joelvaneenwyk/static-web-apps-deploy:develop}"
  echo "TA_REPOSITORY=\"$RAW_GITHUB_REPOSITORY\""
  echo "TA_GHCR_IMAGE=\"ghcr.io/$RAW_GITHUB_REPOSITORY\""

  local RAW_INPUTS_APP_LOCATION="${RAW_INPUTS_APP_LOCATION:-}"
  RAW_INPUTS_APP_LOCATION="${RAW_INPUTS_APP_LOCATION#./}"
  if [[ "$RAW_INPUTS_APP_LOCATION" == "." ]]; then
    RAW_INPUTS_APP_LOCATION=""
  else
    RAW_INPUTS_APP_LOCATION="${RAW_INPUTS_APP_LOCATION#.}"
  fi

  local TA_WORKSPACE_LOCAL_PATH="${RAW_GITHUB_WORKSPACE:-}/$RAW_INPUTS_APP_LOCATION"
  TA_WORKSPACE_LOCAL_PATH="${TA_WORKSPACE_LOCAL_PATH%/}"
  echo "TA_WORKSPACE_LOCAL_PATH=$TA_WORKSPACE_LOCAL_PATH"

  local TA_WORKSPACE_DOCKER_PATH="/workspace/$RAW_INPUTS_APP_LOCATION"
  TA_WORKSPACE_DOCKER_PATH="${TA_WORKSPACE_DOCKER_PATH%/}"
  echo "TA_WORKSPACE_DOCKER_PATH=$TA_WORKSPACE_DOCKER_PATH"

  local RAW_INPUTS_APP_ARTIFACT_LOCATION="${RAW_INPUTS_APP_ARTIFACT_LOCATION:-}"
  RAW_INPUTS_APP_ARTIFACT_LOCATION="${RAW_INPUTS_APP_ARTIFACT_LOCATION#./}"
  local TA_DATA_APP_ARTIFACT_LOCATION="$TA_WORKSPACE_DOCKER_PATH/$RAW_INPUTS_APP_ARTIFACT_LOCATION"
  TA_DATA_APP_ARTIFACT_LOCATION="${TA_DATA_APP_ARTIFACT_LOCATION%/}"

  local RAW_INPUTS_DATA_API_LOCATION="${RAW_INPUTS_DATA_API_LOCATION:-}"
  RAW_INPUTS_DATA_API_LOCATION="${RAW_INPUTS_DATA_API_LOCATION#./}"
  local TA_DATA_API_LOCATION="$TA_WORKSPACE_DOCKER_PATH/$RAW_INPUTS_DATA_API_LOCATION"
  TA_DATA_API_LOCATION="${TA_DATA_API_LOCATION%/}"

  local RAW_INPUTS_ACTION="${RAW_INPUTS_ACTION:-run}"
  echo "TA_CLI_INPUT_ACTION=${RAW_INPUTS_ACTION}"

  if [ "$RAW_INPUTS_ACTION" != "version" ]; then
    echo "TA_CLI_APP_LOCATION=--app \"$TA_WORKSPACE_DOCKER_PATH\""
    echo "TA_CLI_DATA_APP_ARTIFACT_LOCATION=--appArtifactLocation \"$TA_DATA_APP_ARTIFACT_LOCATION\""
    echo "TA_CLI_DATA_API_LOCATION=--api \"$TA_DATA_API_LOCATION\""
    echo "TA_CLI_SKIP_DEPLOY_ON_MISSING_SECRETS=$RAW_INPUTS_SKIP_DEPLOY_ON_MISSING_SECRETS"
    echo "TA_CLI_SKIP_APP_BUILD=$RAW_INPUTS_SKIP_APP_BUILD"

    [ -n "${RAW_INPUTS_AZURE_STATIC_WEB_APPS_API_TOKEN:-}" ] &&
      echo "TA_CLI_AZURE_STATIC_WEB_APPS_API_TOKEN=--apiToken \"$RAW_INPUTS_AZURE_STATIC_WEB_APPS_API_TOKEN\"" ||
      echo "TA_CLI_AZURE_STATIC_WEB_APPS_API_TOKEN="
    echo "AZURE_STATIC_WEB_APPS_API_TOKEN=${RAW_INPUTS_AZURE_STATIC_WEB_APPS_API_TOKEN:-}"
  fi

  # The argument being lower-case as '--deploymentaction' is intentional
  local RAW_DEPLOYMENT_ACTION="close"
  [ "$RAW_INPUTS_ACTION" != "close" ] && RAW_DEPLOYMENT_ACTION="upload"
  echo "TA_CLI_APP_DEPLOYMENT_ACTION=--deploymentaction \"$RAW_DEPLOYMENT_ACTION\""
}
write_env | tee -a "${GITHUB_OUTPUT:-./.env.action_output}"

# GitHub Action for deploying to Azure Static Web Apps

This Github Action enables developers to build and publish their applications to Azure App Service Static Web Apps. This action utilizes [Oryx](https://github.com/microsoft/Oryx) to detect and build an application, then uploads the resulting application content, as well as any Azure Functions, to Azure.

- [More information about Azure Static Web Apps](https://aka.ms/swaDocs)
- [More information about this GitHub Action Workflow](https://aka.ms/swaWorkflowConfig)

## Implementation

This is essentially just a wrapper for the Docker container at `mcr.microsoft.com/appsvc/staticappsclient:stable` with some syntatic sugar and useful defaults. Here is an example of how to call the container manually as shown in [Option For Manual Deployment (Outside Of Actions)](https://github.com/Azure/static-web-apps/issues/96#issuecomment-841072249):

```bash
docker run --entrypoint "/bin/staticsites/StaticSitesClient" \
  --volume "$(pwd)"/build:/root/build \
  mcr.microsoft.com/appsvc/staticappsclient:stable \
  upload \
  --skipAppBuild true \
  --app "/root/build" \
  --apiToken "<token>"
```

## CLI

```bash
StaticSitesClient 1.0.0
Copyright (C) 2024 StaticSitesClient

--verbose                       # Default: false,   Enables verbose logging
--deploymentaction              # Default: N/A,     Specifies the action to run
--workdir                       # Default: N/A,     Working directory of the repository
--buildTimeoutInMinutes         # Default: N/A,     Time limit of oryx build in minutes
--app                           # Default: N/A,     Directory of app source code
--api                           # Default: N/A,     Directory of api source code
--dataApi                       # Default: N/A,     Directory of data api configuration files
--routesLocation                # Default: N/A,     Path to the routes file
--configFileLocation            # Default: N/A,     Path to the staticwebapp.config.json file
--outputLocation                # Default: N/A,     Directory of built application artifacts
--appArtifactLocation           # Default: N/A,     Directory of built application artifacts
--event                         # Default: N/A,     Filepath of the event json
--apiToken                      # Default: N/A,     ApiToken
--repoToken                     # Default: N/A,     RepoToken
--appBuildCommand               # Default: N/A,     App Build Command
--apiBuildCommand               # Default: N/A,     Api Build Command
--repositoryUrl                 # Default: N/A,     Repository Url
--deploymentEnvironment         # Default: N/A,     Deployment Environment
--branch                        # Default: N/A,     Branch
--deploymentProvider            # Default: N/A,     Deployment provider
--skipAppBuild                  # Default: false,   Skips Oryx build for app folder
--skipApiBuild                  # Default: false,   Skips Oryx build for api folder
--skipDeployOnMissingSecrets    # Default: false,   Skips deployment if api token isn't specified.
--isStaticExport                # Default: false,   Repository uses Static Export of Site
--pullRequestTitle              # Pull request title for staging sites.
--headBranch                    # Head branch name for staging sites.
--productionBranch              # Production branch. When specified, deployments from other branches will be staging environments.
--help                          # Display this help screen.
--version                       # Display version information.
```

## Example

```powershell
docker run \
    --name "test_id_12345" \
    --label "deadbeef" \
    --workdir /github/workspace --rm \
    -e "GOPROXY" -e "GO111MODULE" \
    -e "SASS_VERSION" -e "DART_SASS_SHA_LINUX" \
    -e "DART_SASS_SHA_MACOS" -e "DART_SASS_SHA_WINDOWS" \
    -e "STATIC_APP_LOCATION" -e "STATIC_API_LOCATION" \
    -e "STATIC_OUTPUT_LOCATION" -e "pythonLocation" \
    -e "PKG_CONFIG_PATH" \
    -e "Python_ROOT_DIR" \
    -e "Python2_ROOT_DIR" \
    -e "Python3_ROOT_DIR" \
    -e "LD_LIBRARY_PATH" \
    -e "INPUT_AZURE_STATIC_WEB_APPS_API_TOKEN" \
    -e "INPUT_ACTION" \
    -e "INPUT_APP_LOCATION" -e "INPUT_API_LOCATION" \
    -e "INPUT_OUTPUT_LOCATION" -e "INPUT_REPO_TOKEN" \
    -e "INPUT_API_BUILD_COMMAND" -e "INPUT_APP_ARTIFACT_LOCATION" \
    -e "INPUT_APP_BUILD_COMMAND" -e "INPUT_ROUTES_LOCATION" \
    -e "INPUT_SKIP_APP_BUILD" -e "INPUT_CONFIG_FILE_LOCATION" \
    -e "INPUT_SKIP_API_BUILD" -e "INPUT_PRODUCTION_BRANCH" \
    -e "INPUT_DEPLOYMENT_ENVIRONMENT" -e "INPUT_IS_STATIC_EXPORT" \
    -e "INPUT_DATA_API_LOCATION" -e "HOME" \
    -e "GITHUB_JOB" -e "GITHUB_REF" \
    -e "GITHUB_SHA" -e "GITHUB_REPOSITORY" \
    -e "GITHUB_REPOSITORY_OWNER" -e "GITHUB_REPOSITORY_OWNER_ID" \
    -e "GITHUB_RUN_ID" \
    -e "GITHUB_RUN_NUMBER" -e "GITHUB_RETENTION_DAYS" \
    -e "GITHUB_RUN_ATTEMPT" \
    -e "GITHUB_REPOSITORY_ID" -e "GITHUB_ACTOR_ID" \
    -e "GITHUB_ACTOR" \
    -e "GITHUB_TRIGGERING_ACTOR" -e "GITHUB_WORKFLOW" \
    -e "GITHUB_HEAD_REF" \
    -e "GITHUB_BASE_REF" -e "GITHUB_EVENT_NAME" \
    -e "GITHUB_SERVER_URL" \
    -e "GITHUB_API_URL" -e "GITHUB_GRAPHQL_URL" \
    -e "GITHUB_REF_NAME" \
    -e "GITHUB_REF_PROTECTED" -e "GITHUB_REF_TYPE" \
    -e "GITHUB_WORKFLOW_REF" \
    -e "GITHUB_WORKFLOW_SHA" -e "GITHUB_WORKSPACE" \
    -e "GITHUB_ACTION" \
    -e "GITHUB_EVENT_PATH" -e "GITHUB_ACTION_REPOSITORY" \
    -e "GITHUB_ACTION_REF" \
    -e "GITHUB_PATH" -e "GITHUB_ENV" \
    -e "GITHUB_STEP_SUMMARY" \
    -e "GITHUB_STATE" -e "GITHUB_OUTPUT" \
    -e "RUNNER_OS" \
    -e "RUNNER_ARCH" -e "RUNNER_NAME" \
    -e "RUNNER_ENVIRONMENT" \
    -e "RUNNER_TOOL_CACHE" -e "RUNNER_TEMP" \
    -e "RUNNER_WORKSPACE" \
    -e "ACTIONS_RUNTIME_URL" -e "ACTIONS_RUNTIME_TOKEN" \
    -e "ACTIONS_CACHE_URL" \
    -e "ACTIONS_ID_TOKEN_REQUEST_URL" -e "ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
    -e "ACTIONS_RESULTS_URL" \
    -e GITHUB_ACTIONS=true \
    -e CI=true \
    -v "/var/run/docker.sock":"/var/run/docker.sock" \
    -v "/home/runner/work/_temp/_github_home":"/github/home" \
    -v "/home/runner/work/_temp/_github_workflow":"/github/workflow" \
    -v "/home/runner/work/_temp/_runner_file_commands":"/github/file_commands" \
    -v "/home/runner/work/static-web-app-test-repo/static-web-app-test-repo":"/github/workspace" \
    de6750:d0c46eb031cf4c8190848f0e534abbaa
```

## Issues and Feedback

If you'd like to report an issue or provide feedback, please create issues against this [repository](https://github.com/azure/static-web-apps).

## Contributing

This project welcomes contributions and suggestions. Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit <https://cla.opensource.microsoft.com>.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

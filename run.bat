@echo off
goto:$Main

:Command
setlocal EnableDelayedExpansion
    set "_command=%*"
    set "_command=!_command:     = !"
    set "_command=!_command:   = !"
    set "_command=!_command:  = !"
    set "_command=!_command:  = !"
    echo ##[cmd] !_command!
    call !_command!
endlocal & exit /b %ERRORLEVEL%

:$Main
setlocal EnableDelayedExpansion
    set "_root=%~dp0"
    if "%_root:~-1%"=="\" set "_root=%_root:~0,-1%"
    cd /D "!_root!"
    set "_name=static_web_apps_deploy"
    set "_tag=%_name%:latest"
    set "_container=%_name%_container"
    set "_label=%_name%_label"

    set BUILDKIT_PROGRESS=plain

    call :Command docker build --no-cache --progress=plain -t "!_tag!" "!_root!"
    call :Command docker run ^
        -p 1313:1313 ^
        -it ^
        --restart=no ^
        --log-driver local --log-opt max-size=10m --log-opt max-file=3 ^
        --workdir /github/workspace ^
        --rm ^
        -v "!_root!:/github/workspace" ^
        --name "!_container!" ^
        --label "!_label!" ^
        -e STATIC_APP_LOCATION="./test/public" ^
        "!_tag!" %*
endlocal & exit /b %errorlevel%

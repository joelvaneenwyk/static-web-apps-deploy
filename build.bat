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
    !_command!
endlocal & exit /b %ERRORLEVEL%

:$Main
setlocal EnableDelayedExpansion
    set "_root=%~dp0"
    if "%_root:~-1%"=="\" set "_root=%_root:~0,-1%"
    cd /D "!_root!"
    set "_name=static_web_apps_deploy"
    set "_tag=%_name%:latest"
    set "_container=%_name%_container"
    call :Command docker build --progress=plain -t "!_tag!" "!_root!"
    call :Command docker run ^
        -p 1313:1313 ^
        -it ^
        --rm ^
        -v "!_root!:/github/workspace" ^
        --name "!_container!" ^
        -e STATIC_APP_LOCATION="./test/public" ^
        "!_tag!" %*
endlocal & exit /b %errorlevel%

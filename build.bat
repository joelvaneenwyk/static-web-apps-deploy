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
    call :Command "%~dp0run.bat" ^
        --workdir "/github/workspace" ^
        --app "./test" --appBuildCommand="hugo" ^
        --outputLocation="./test/public" ^
        --verbose ^
        --skipApiBuild --skipDeployOnMissingSecrets
endlocal & exit /b %errorlevel%

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
    call :Command "%~dp0run.bat" build --appBuildCommand="hugo" --outputLocation="./test/public" --verbose=silly api="./test"
endlocal & exit /b %errorlevel%

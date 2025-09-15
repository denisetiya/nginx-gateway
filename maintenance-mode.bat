@echo off
setlocal

REM Script to enable/disable maintenance mode
REM Usage: maintenance-mode.bat [on|off]

if "%~1"=="" (
    echo Usage: %0 [on^|off]
    exit /b 1
)

set MODE=%~1

if "%MODE%"=="on" (
    echo Enabling maintenance mode...
    docker-compose exec nginx touch /etc/nginx/maintenance.on
    docker-compose exec nginx nginx -s reload
    echo Maintenance mode enabled
) else if "%MODE%"=="off" (
    echo Disabling maintenance mode...
    docker-compose exec nginx rm -f /etc/nginx/maintenance.on
    docker-compose exec nginx nginx -s reload
    echo Maintenance mode disabled
) else (
    echo Invalid option. Use 'on' or 'off'
    exit /b 1
)
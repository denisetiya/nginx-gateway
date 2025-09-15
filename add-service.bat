@echo off
setlocal

REM Script to add a new service to the Nginx gateway
REM Usage: add-service.bat SERVICE_NAME SERVICE_PORT SERVICE_PREFIX DOMAIN

if "%~4"=="" (
    echo Usage: %0 SERVICE_NAME SERVICE_PORT SERVICE_PREFIX DOMAIN
    echo Example: %0 user-service 3000 /api/users example.com
    exit /b 1
)

set SERVICE_NAME=%~1
set SERVICE_PORT=%~2
set SERVICE_PREFIX=%~3
set DOMAIN=%~4

REM Create service configuration from template
copy conf.d\service-template.conf conf.d\%SERVICE_NAME%.conf >nul

REM Replace placeholders with actual values
powershell -Command "(gc conf.d\%SERVICE_NAME%.conf) -replace 'SERVICE_NAME', '%SERVICE_NAME%' | Out-File -encoding ASCII conf.d\%SERVICE_NAME%.conf"
powershell -Command "(gc conf.d\%SERVICE_NAME%.conf) -replace 'SERVICE_PORT', '%SERVICE_PORT%' | Out-File -encoding ASCII conf.d\%SERVICE_NAME%.conf"
powershell -Command "(gc conf.d\%SERVICE_NAME%.conf) -replace 'SERVICE_PREFIX', '%SERVICE_PREFIX%' | Out-File -encoding ASCII conf.d\%SERVICE_NAME%.conf"
powershell -Command "(gc conf.d\%SERVICE_NAME%.conf) -replace 'YOUR_DOMAIN', '%DOMAIN%' | Out-File -encoding ASCII conf.d\%SERVICE_NAME%.conf"

echo Service %SERVICE_NAME% added with prefix %SERVICE_PREFIX% on port %SERVICE_PORT%
echo Configuration file created at conf.d\%SERVICE_NAME%.conf
echo Restart Nginx to apply changes: docker-compose restart nginx
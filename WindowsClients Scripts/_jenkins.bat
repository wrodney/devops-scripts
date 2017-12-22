@ECHO OFF
cd /d "%~dp0"
SET BUILD_CONFIG=%~1

:: Pass in build config as argument, default to Debug
if [%BUILD_CONFIG%]==[] set BUILD_CONFIG="Debug"

:: Using Jenkins build_number environment variable to determine revision
if [%BUILD_NUMBER%]==[] set BUILD_NUMBER="1"

:: Clear the publish area of any artifacts if running in Jenkins
if not [%JENKINS_HOME%]==[] del artifacts\*.zip /s

::
powershell -NoLogo -ExecutionPolicy Bypass -File .\build_Desktop.ps1 -revision %BUILD_NUMBER% -buildConfig %BUILD_CONFIG%

exit /B %ERRORLEVEL%

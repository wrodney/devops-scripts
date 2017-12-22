@ECHO OFF
cd /d "%~dp0"
SET TASK_NAME=%~1
SET BUILD_CONFIG=%~2
SET LIVE=%~3

:: Pass in task name as argument, default to Build.DEV
if [%TASK_NAME%]==[] set TASK_NAME="Build.DEV"

:: Pass in build config as argument, default to DEV
if [%BUILD_CONFIG%]==[] set BUILD_CONFIG="DEV"

:: Using Jenkins build_number environment variable to determine revision
if [%BUILD_NUMBER%]==[] set BUILD_NUMBER="1"

::
if not [%LIVE%]==[] set LIVE="-liveNuGet"

:: Clear the publish area of any artifacts if running in Jenkins
if not [%JENKINS_HOME%]==[] del ..\publish\apps\*.exe /s
if not [%JENKINS_HOME%]==[] del ..\publish\nuget\*.nupkg /s
if not [%JENKINS_HOME%]==[] rd ..\publish\sql /s /q

:: Run pSake
powershell -NoLogo -ExecutionPolicy Bypass -File .\_build.ps1 -taskName %TASK_NAME% -buildConfig %BUILD_CONFIG% -revision %BUILD_NUMBER% -packageRestore %LIVE% 

exit /B %ERRORLEVEL%

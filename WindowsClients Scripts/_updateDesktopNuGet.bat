@ECHO OFF
cd /d "%~dp0"

SET SLN=..\source\WindowsDesktop.sln
SET CMN_ARGS=-repositoryPath ..\source\packages -verbose -source http://artifactory-clt.devtms.local:8081/artifactory/api/nuget/teams-nuget-local

tools\nuget.exe update %SLN% -Id Diligent.Teams.Client.Windows %CMN_ARGS%
tools\nuget.exe update %SLN% -Id Diligent.Teams.Core %CMN_ARGS%


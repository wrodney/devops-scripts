@ECHO OFF
cd /d "%~dp0"

SET CMN_ARGS=-repositoryPath ..\source\packages -verbose 

tools\nuget.exe update ..\source\_Core\Diligent.Research.Core.sln %CMN_ARGS%

tools\nuget.exe update ..\source\DataModel\Diligent.Research.Data.Modeling.sln %CMN_ARGS%

tools\nuget.exe update ..\source\Services\PlatformService\Diligent.Research.Services.Platform.sln %CMN_ARGS%
tools\nuget.exe update ..\source\Services\IdentityService\Diligent.Research.Services.Identity.sln %CMN_ARGS%
tools\nuget.exe update ..\source\Services\KeyManagementService\Diligent.Research.Services.KeyManagement.sln %CMN_ARGS%
tools\nuget.exe update ..\source\Services\SmtpService\Diligent.Research.Services.Smtp.sln %CMN_ARGS%
tools\nuget.exe update ..\source\Services\SystemsService\Diligent.Research.Services.Systems.sln %CMN_ARGS%

tools\nuget.exe update ..\source\Broker\BrokerService\Diligent.Research.Services.Broker.sln %CMN_ARGS%
tools\nuget.exe update ..\source\Broker\PublicWebAPI\Diligent.Research.Web.PublicWebAPI.sln %CMN_ARGS%
tools\nuget.exe update ..\source\Broker\SocketService\Diligent.Research.Services.Socket.sln %CMN_ARGS%
        
tools\nuget.exe update ..\source\DMZ\Deployment\Diligent.Research.Web.Deployment.sln %CMN_ARGS%

tools\nuget.exe update ..\source\Apps\AuthProvider\Diligent.Research.Apps.AuthProvider.sln %CMN_ARGS%
tools\nuget.exe update ..\source\Apps\AuthConnector\Diligent.Research.Apps.AuthConnector.sln %CMN_ARGS%
tools\nuget.exe update ..\source\Apps\AuthConnectorHosted\Diligent.Research.Apps.AuthConnectorHosted.sln %CMN_ARGS%
tools\nuget.exe update ..\source\Apps\AuthConnectorProxy\Diligent.Research.Apps.AuthConnectorProxy.sln %CMN_ARGS%
tools\nuget.exe update ..\source\Apps\LogReader\Diligent.Research.Apps.LogReader.sln %CMN_ARGS%
tools\nuget.exe update ..\source\Apps\DesktopClient\Diligent.Research.Apps.DesktopClient.sln %CMN_ARGS%
tools\nuget.exe update ..\source\Apps\TeamsAdminClient\Diligent.Research.Apps.TeamsAdminClient.sln %CMN_ARGS%

tools\nuget.exe update ..\source\Utility\KeyFactoryCmd\KeyFactoryCmd.sln %CMN_ARGS%
tools\nuget.exe update ..\source\Utility\SqlPackageInstall\SqlPackageInstall.sln %CMN_ARGS%
tools\nuget.exe update ..\source\Utility\PasswordHashUtility\PasswordHashUtility.sln %CMN_ARGS%

tools\nuget.exe update ..\source\Services\AllInOneService\Diligent.Research.Services.AllInOne.sln %CMN_ARGS%



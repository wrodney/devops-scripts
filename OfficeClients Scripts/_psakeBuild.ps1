properties {
    $base_directory = Resolve-Path ..\ 
    $src_directory = "$base_directory\source"
    $scripts_path = "$base_directory\scripts"

    $publish_path = "$base_directory\publish"
    $nuget_publish_path = "$base_directory\publish\nuget"
    $apps_publish_path = "$base_directory\publish\apps"
    $sql_publish_path = "$base_directory\publish\sql"
    
    $nuget_exe = "$scripts_path\tools\nuget.exe"
    $ilmerge_exe = "$scripts_path\tools\ILMerge.exe"
    $nsis_exe = "$scripts_path\tools\nsis\makensis.exe"
    $pkzip_exe = "$scripts_path\tools\pkzipc.exe"

    $nunit_console_exe = "$scripts_path\tools\NUnit.2.6.4\nunit-console-x86.exe"

    $key_file = "$src_directory\Diligent.Research.snk"

    $bulidConfigs = @(
        "Debug",
        "CI",
        "DEMO",
        "DEV",
        "STABLE",
        "QA",
        "UAT",
        "PROD"
    )

    $certificates = @(
        @{Thumbprint="8E29371AAA33731F87948EA2D959D9F8DF2CFB30"; Target="cert:\LocalMachine\My"; Source="certificates\star.diligentdatasystems.com-020217-pass-diligent.pfx";};
        @{Thumbprint="867C00ABBC514A50BE2A591ECBF3944E39BA220F"; Target="cert:\LocalMachine\TrustedPeople"; Source="certificates\Diligent.Boardbooks.SecureDataTransfer-pass-diligent.pfx";};
    );

    $hardwareConfig = @(
        @{
            Name = "Sql";

            Hardware = @(
                @{ BuildName = "DEV"; MachineName = "clt01d1app11.devtms.local"; DirectoryPath = "\\clt01d1app11.devtms.local\deploy\Research" },
                @{ BuildName = "DEMO"; MachineName = "clt01d1web14.devtms.local"; DirectoryPath = "\\clt01d1web14.devtms.local\deploy\Research" },
                @{ BuildName = "STABLE"; MachineName = "clt01d1web13.devtms.local"; DirectoryPath = "\\clt01d1web13.devtms.local\deploy\Research" },
                @{ BuildName = "QA"; MachineName = "clt01d1app14.devtms.local"; DirectoryPath = "\\clt01d1app14.devtms.local\deploy\Research" }
            )

            Apps = @(
                @{ Name = "SqlPackageInstall"; FileName = "SqlPackageInstall.$assemblyFileVersion.$environmentName.exe"; Instances = 1 }
            )
        };
        @{
            Name = "Services";

            Hardware = @(
                @{ BuildName = "DEV"; MachineName = "clt01d1app12.devtms.local"; DirectoryPath = "\\clt01d1app12.devtms.local\deploy\Research" },
                @{ BuildName = "DEMO"; MachineName = "clt01d1web14.devtms.local"; DirectoryPath = "\\clt01d1web14.devtms.local\deploy\Research" },
                @{ BuildName = "STABLE"; MachineName = "clt01d1web13.devtms.local"; DirectoryPath = "\\clt01d1web13.devtms.local\deploy\Research" },
                @{ BuildName = "QA"; MachineName = "clt01d1app15.devtms.local"; DirectoryPath = "\\clt01d1app15.devtms.local\deploy\Research" }
            )

            Apps = @(
                @{ Name = "IdentityService"; FileName = "Diligent.Research.Services.Identity.$assemblyFileVersion.*.$environmentName.exe"; Instances = 2 },
                @{ Name = "PlatformService"; FileName = "Diligent.Research.Services.Platform.$assemblyFileVersion.*.$environmentName.exe"; Instances = 2 },
                @{ Name = "KeyManagementService"; FileName = "Diligent.Research.Services.KeyManagement.$assemblyFileVersion.*.$environmentName.exe"; Instances = 2 },
                @{ Name = "SmtpService"; FileName = "Diligent.Research.Services.Smtp.$assemblyFileVersion.*.$environmentName.exe"; Instances = 2 },
                @{ Name = "SystemsService"; FileName = "Diligent.Research.Services.Systems.$assemblyFileVersion.*.$environmentName.exe"; Instances = 2 },
                @{ Name = "JobsService"; FileName = "Diligent.Research.Services.Jobs.$assemblyFileVersion.*.$environmentName.exe"; Instances = 1 }
            )
        };
        @{
            Name = "RabbitMQ";

            Hardware = @(
                @{ BuildName = "DEV"; MachineName = "clt01d1app13.devtms.local"; DirectoryPath = "\\clt01d1app13.devtms.local\deploy\Research" },
                @{ BuildName = "DEMO"; MachineName = "clt01d1web14.devtms.local"; DirectoryPath = "\\clt01d1web14.devtms.local\deploy\Research" },
                @{ BuildName = "STABLE"; MachineName = "clt01d1web13.devtms.local"; DirectoryPath = "\\clt01d1web13.devtms.local\deploy\Research" },
                @{ BuildName = "QA"; MachineName = "clt01d1app16.devtms.local"; DirectoryPath = "\\clt01d1app16.devtms.local\deploy\Research" }
            )

            Apps = @()
        };
        @{
            Name = "Broker";

            Hardware = @(
                @{ BuildName = "DEV"; MachineName = "clt01d1web19.devtms.local"; DirectoryPath = "\\clt01d1web19.devtms.local\deploy\Research" },
                @{ BuildName = "DEMO"; MachineName = "clt01d1web14.devtms.local"; DirectoryPath = "\\clt01d1web14.devtms.local\deploy\Research" },
                @{ BuildName = "STABLE"; MachineName = "clt01d1web13.devtms.local"; DirectoryPath = "\\clt01d1web13.devtms.local\deploy\Research" },
                @{ BuildName = "QA"; MachineName = "clt01d1web17.devtms.local"; DirectoryPath = "\\clt01d1web17.devtms.local\deploy\Research" }
            )

            Apps = @(
                @{ Name = "Broker"; FileName = "Diligent.Research.Services.Broker.$assemblyFileVersion.*.$environmentName.exe"; Instances = 2 },
                @{ Name = "PublicWebApi"; FileName = "Diligent.Research.Web.PublicWebApi.Service.$assemblyFileVersion.*.$environmentName.exe"; Instances = 2 },
                @{ Name = "Socket"; FileName = "Diligent.Research.Services.Socket.$assemblyFileVersion.*.$environmentName.exe"; Instances = 2 }
            )
        };
        @{
            Name = "DMZ";

            Hardware = @(
                @{ BuildName = "DEV"; MachineName = "clt01d1web20.devtms.local"; DirectoryPath = "\\clt01d1web20.devtms.local\deploy\Research" },
                @{ BuildName = "DEMO"; MachineName = "clt01d1web14.devtms.local"; DirectoryPath = "\\clt01d1web14.devtms.local\deploy\Research" },
                @{ BuildName = "STABLE"; MachineName = "clt01d1web13.devtms.local"; DirectoryPath = "\\clt01d1web13.devtms.local\deploy\Research" },
                @{ BuildName = "QA"; MachineName = "clt01d1web18.devtms.local"; DirectoryPath = "\\clt01d1web18.devtms.local\deploy\Research" }
            )

            Apps = @(
                @{ Name = "Deployment"; FileName = "Diligent.Research.Web.Deployment.Service.$assemblyFileVersion.*.$environmentName.exe"; Instances = 1 },
                @{ Name = "AuthProvider"; FileName = "Diligent.Research.Apps.AuthProvider.Service.$assemblyFileVersion.*.$environmentName.exe"; Instances = 1 },
                @{ Name = "AuthConnectorHosted"; FileName = "Diligent.Research.Apps.AuthConnectorHosted.Service.$assemblyFileVersion.*.$environmentName.exe"; Instances = 1 },

                @{ Name = "DesktopClient"; FileName = "Diligent.Research.Apps.DesktopClient.$assemblyFileVersion.$environmentName.exe"; Instances = 1 },
                @{ Name = "TeamsAdminClient"; FileName = "Diligent.Research.Apps.TeamsAdminClient.$assemblyFileVersion.$environmentName.exe"; Instances = 1 }
            )
        };
        @{
            Name = "Client";

            Hardware = @(
                @{ BuildName = "DEV"; MachineName = "clt01d1web15.devtms.local"; DirectoryPath = "\\clt01d1web15.devtms.local\deploy\Research" },
                @{ BuildName = "DEMO"; MachineName = "clt01d1web14.devtms.local"; DirectoryPath = "\\clt01d1web14.devtms.local\deploy\Research" },
                @{ BuildName = "STABLE"; MachineName = "clt01d1web13.devtms.local"; DirectoryPath = "\\clt01d1web13.devtms.local\deploy\Research" },
                @{ BuildName = "QA"; MachineName = "clt01d1web16.devtms.local"; DirectoryPath = "\\clt01d1web18.devtms.local\deploy\Research" }
            )

            Apps = @(
                @{ Name = "AuthConnector"; FileName = "Diligent.Research.Apps.AuthConnector.Service.$assemblyFileVersion.*.$environmentName.exe"; Instances = 1 },
                @{ Name = "AuthConnectorProxy"; FileName = "Diligent.Research.Apps.AuthConnectorProxy.Service.$assemblyFileVersion.*.$environmentName.exe"; Instances = 1 }
            )
        };
    )

}

# 
. .\compileSolutions.ps1
. .\unitTests.ps1
. .\deploy.ps1 

#
. .\vs\Set-ProjectProperties.ps1

# NuGet Packages
. .\publish\nuget\nuget.ps1
. .\publish\nuget\Diligent.Research.Core\Diligent.Research.Core.ps1
. .\publish\nuget\Diligent.Research.Data\Diligent.Research.Data.ps1
. .\publish\nuget\Diligent.Research.Client.Windows\Diligent.Research.Client.Windows.ps1
. .\publish\nuget\Diligent.Research.Messaging\Diligent.Research.Messaging.ps1
. .\publish\nuget\Diligent.Research.Service\Diligent.Research.Service.ps1
. .\publish\nuget\Diligent.Research.ServiceBus.Broker\Diligent.Research.ServiceBus.Broker.ps1
. .\publish\nuget\Diligent.Research.ServiceBus.Service\Diligent.Research.ServiceBus.Service.ps1
. .\publish\nuget\Diligent.Research.Test.Core\Diligent.Research.Test.Core.ps1


# App Install Packages
. .\publish\apps\Broker.Broker\Broker.Broker.ps1
. .\publish\apps\Broker.PublicWebApi\Broker.PublicWebApi.ps1
. .\publish\apps\Broker.Socket\Broker.Socket.ps1

. .\publish\apps\Services.Identity\Services.Identity.ps1
. .\publish\apps\Services.Platform\Services.Platform.ps1
. .\publish\apps\Services.KeyManagement\Services.KeyManagement.ps1
. .\publish\apps\Services.Smtp\Services.Smtp.ps1
. .\publish\apps\Services.Systems\Services.Systems.ps1
. .\publish\apps\Services.Jobs\Services.Jobs.ps1

. .\publish\apps\Web.Deployment\Web.Deployment.ps1

. .\publish\apps\Apps.AuthProvider\Apps.AuthProvider.ps1
. .\publish\apps\Apps.AuthConnector\Apps.AuthConnector.ps1
. .\publish\apps\Apps.AuthConnectorHosted\Apps.AuthConnectorHosted.ps1
. .\publish\apps\Apps.AuthConnectorProxy\Apps.AuthConnectorProxy.ps1
. .\publish\apps\Apps.DesktopClient\Apps.DesktopClient.ps1
. .\publish\apps\Apps.TeamsAdminClient\Apps.TeamsAdminClient.ps1

. .\publish\apps\Utility.SqlPackageInstall\Utility.SqlPackageInstall.ps1

# Sql Install Scripts
. .\publish\sql\publishSql.ps1


task Publish.Apps -description "Publish everything" {

    Invoke-Task Publish.Broker
    Invoke-Task Publish.PublicWebApi
    Invoke-Task Publish.Socket

    Invoke-Task Publish.Services.Identity
    Invoke-Task Publish.Services.Platform
    Invoke-Task Publish.Services.KeyManagement
    Invoke-Task Publish.Services.Smtp
    Invoke-Task Publish.Services.Systems
    Invoke-Task Publish.Services.Jobs
    
    Invoke-Task Publish.Web.Deployment

    Invoke-Task Publish.Apps.AuthProvider
    Invoke-Task Publish.Apps.AuthConnector
    Invoke-Task Publish.Apps.AuthConnectorHosted
    Invoke-Task Publish.Apps.AuthConnectorProxy

    Invoke-Task Publish.Apps.DesktopClient
    Invoke-Task Publish.Apps.TeamsAdminClient
    
    Invoke-Task Publish.Utility.SqlPackageInstall
}

task Publish.NuGet -description "Publish everything" {

    Invoke-Task Publish.NuGet.Core
    Invoke-Task Publish.NuGet.Data
    Invoke-Task Publish.NuGet.Messaging
    Invoke-Task Publish.NuGet.Service
    Invoke-Task Publish.NuGet.ServiceBus.Broker
    Invoke-Task Publish.NuGet.ServiceBus.Service
    Invoke-Task Publish.NuGet.Client.Windows
    Invoke-Task Publish.NuGet.Test.Core
}

task Push.NuGet -description "Push NuGet" {

    Invoke-Task Push.NuGet.Core
    Invoke-Task Push.NuGet.Data
    Invoke-Task Push.NuGet.Messaging
    Invoke-Task Push.NuGet.Service
    Invoke-Task Push.NuGet.ServiceBus.Broker
    Invoke-Task Push.NuGet.ServiceBus.Service
    Invoke-Task Push.NuGet.Client.Windows
    Invoke-Task Push.NuGet.Test.Core
}

task Build.Debug -description "Debug Build" {

    Invoke-Task Compile.Code
}


task Build.CI -description "CI Build" {

    Invoke-Task Compile.Code

    # TODO: In the future, have a CI environment to contain any bleeding-edge code to demonstrate features quickly...
    #Invoke-Task Deploy.Copy
}

task Build.DEV -description "DEV Build and publish apps and nuget packages" {

    Invoke-Task Compile.Code
    Invoke-Task Run.UnitTests

    Invoke-Task Publish.NuGet
    Invoke-Task Push.NuGet

    Invoke-Task Publish.Apps
    Invoke-Task Publish.Sql
    
    Invoke-Task Deploy.Copy
}

task Build.DEMO -description "DEMO Build" {

    Invoke-Task Compile.Code
    Invoke-Task Publish.Apps
    Invoke-Task Publish.Sql
    Invoke-Task Deploy.Copy
}

task Build.STABLE -description "STABLE Build and publish apps and nuget packages" {
    
    Invoke-Task Compile.Code
    Invoke-Task Run.UnitTests

    Invoke-Task Publish.NuGet
    Invoke-Task Push.NuGet

    Invoke-Task Publish.Apps
    Invoke-Task Publish.Sql
    
    Invoke-Task Deploy.Copy
}


task Build.QA -description "QA Build and publish apps" {

    Invoke-Task Compile.Code
    Invoke-Task Run.UnitTests
    Invoke-Task Publish.Apps
    Invoke-Task Publish.Sql
    Invoke-Task Deploy.Copy
}

task Configure.VS -description "Update all .csproj with the latest settings" {

    # Set all .csproj with the default settings
    dir -recurse $src_directory\*.csproj | `
        Set-ProjectProperties

    # Set all .csproj with define constansts per build configuration
    dir -recurse $src_directory\*.csproj | `
        Set-ProjectProperties `
            -OverrideDefaultProperties `
            -Configurations "CI" `
            -CustomConfigurationProperties @{ "DefineConstants" = 
                {
                    param($config)
                    $defines = $config.GetElementsByTagName("DefineConstants")
                    $defines[0].InnerText = "TRACE;CI"
                } 
            }

    dir -recurse $src_directory\*.csproj | `
        Set-ProjectProperties `
            -OverrideDefaultProperties `
            -Configurations "DEMO" `
            -CustomConfigurationProperties @{ "DefineConstants" = 
                {
                    param($config)
                    $defines = $config.GetElementsByTagName("DefineConstants")
                    $defines[0].InnerText = "TRACE;DEMO"
                } 
            }

    dir -recurse $src_directory\*.csproj | `
        Set-ProjectProperties `
            -OverrideDefaultProperties `
            -Configurations "DEV" `
            -CustomConfigurationProperties @{ "DefineConstants" = 
                {
                    param($config)
                    $defines = $config.GetElementsByTagName("DefineConstants")
                    $defines[0].InnerText = "TRACE;DEV"
                } 
            }

    dir -recurse $src_directory\*.csproj | `
        Set-ProjectProperties `
            -OverrideDefaultProperties `
            -Configurations "QA" `
            -CustomConfigurationProperties @{ "DefineConstants" = 
                {
                    param($config)
                    $defines = $config.GetElementsByTagName("DefineConstants")
                    $defines[0].InnerText = "TRACE;QA"
                } 
            }

    dir -recurse $src_directory\*.csproj | `
        Set-ProjectProperties `
            -OverrideDefaultProperties `
            -Configurations "UAT" `
            -CustomConfigurationProperties @{ "DefineConstants" = 
                {
                    param($config)
                    $defines = $config.GetElementsByTagName("DefineConstants")
                    $defines[0].InnerText = "TRACE;UAT"
                } 
            }

    dir -recurse $src_directory\*.csproj | `
        Set-ProjectProperties `
            -OverrideDefaultProperties `
            -Configurations "PROD" `
            -CustomConfigurationProperties @{ "DefineConstants" = 
                {
                    param($config)
                    $defines = $config.GetElementsByTagName("DefineConstants")
                    $defines[0].InnerText = "TRACE;PROD"
                } 
            }

}

task default 

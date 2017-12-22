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

    $key_file = "$src_directory\Diligent.Teams.snk"

    $bulidConfigs = @(
        "Debug",
        "CI",
        "DEMO",
        "DEV",
        "QA",
        "UAT",
        "PROD"
    )

    $hardwareConfig = @(
        @{
            Name = "Client";

            Hardware = @(
                @{ BuildName = "DEV"; MachineName = "clt01d1web14.devtms.local"; DirectoryPath = "\\clt01d1web14.devtms.local\deploy\Teams" },
                @{ BuildName = "STABLE"; MachineName = "clt01d1web13.devtms.local"; DirectoryPath = "\\clt01d1web13.devtms.local\deploy\Teams" },
                @{ BuildName = "DEMO"; MachineName = "clt01d1web14.devtms.local"; DirectoryPath = "\\clt01d1web14.devtms.local\deploy\Teams" },
                @{ BuildName = "QA"; MachineName = "clt01d1web16.devtms.local"; DirectoryPath = "\\clt01d1web18.devtms.local\deploy\Teams" }
            )

            Apps = @(
            )
        };
    )

}

# 
. .\compileSolutions.ps1
. .\unitTests.ps1
. .\deploy.ps1 


task Publish.Apps -description "Publish everything" {

    Invoke-Task Publish.Services.Annotation
    Invoke-Task Publish.Services.Conversion
    Invoke-Task Publish.Services.Document
    Invoke-Task Publish.Services.Permission
    Invoke-Task Publish.Services.Role
    Invoke-Task Publish.Services.Section
    Invoke-Task Publish.Services.Transfer
    Invoke-Task Publish.Services.User
}

task Push.All -description "Push everything" {

    Invoke-Task Push.NuGet.Core
    Invoke-Task Push.NuGet.Client.Windows
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
    Invoke-Task Publish.Apps
    Invoke-Task Publish.Sql
    Invoke-Task Push.All
    Invoke-Task Deploy.Copy
}

task Build.STABLE -description "STABLE Build and publish apps and nuget packages" {

    Invoke-Task Compile.Code
    Invoke-Task Run.UnitTests
    Invoke-Task Publish.NuGet
    Invoke-Task Publish.Apps
    Invoke-Task Publish.Sql
    Invoke-Task Push.All
    Invoke-Task Deploy.Copy
}


task Build.DEMO -description "DEMO Build" {

    Invoke-Task Compile.Code
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

task default 

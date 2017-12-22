
    param (
        [string]$environment = "Debug",

        [string]$taskName,
        [switch]$packageRestore = $false,
        [string]$revision,
        [string]$buildConfig,
        [switch]$liveNuGet = $false
    )

    $this_directory = Resolve-Path .
    $src_directory = Resolve-Path ..\source    
    
    $global:buildMajor   = "0"
    $global:buildMinor   = "5"
    $global:buildRelease = "0"
    $global:buildNumber  = $revision
    $global:assemblyFileVersion = ""
    $global:assemblyVersion = ""


    $global:environmentName = $buildConfig


    
    # If a environment name was not passed in, default to "Debug"
    if ($environmentName -eq $null -Or $environmentName -eq "") {
        $global:environmentName = "Debug"
    }

    

    if ($buildNumber -eq $null -Or $buildNumber -eq "") {
        
        # If a revision wasn't supplied, then just use 1.
        $global:buildNumber = 1

        <#
        $buildCounterFilePath = [System.IO.Path]::Combine($this_directory, "buildCounter");
        $buildCounterContents = $null;
    
        if (test-path $buildCounterFilePath) {
            $buildCounterContents = get-content $buildCounterFilePath
        }
    
        if ($buildCounterContents -ne $null) {
            $global:buildNumber = [int]$buildCounterContents
        }
        else {
            $global:buildNumber = 1
        }
        
        [int]$nextBuild = [int]$global:buildNumber + 1
    
        set-content $buildCounterFilePath $nextBuild
        #>
    }

    $global:assemblyFileVersion="$global:buildMajor.$global:buildMinor.$global:buildRelease.$global:buildNumber"
    $global:assemblyVersion="$global:buildMajor.$global:buildMinor.0.0"
    $global:shortVersion="$global:buildMajor.$global:buildMinor"

    # If the packages directory is empty, then get every package using nuget.exe
    if ( $packageRestore -eq $true ) {
        Write-Host "Restoring "

        $nuget_exe_path = [System.IO.Path]::Combine($this_directory, "tools");

        # Find every packages.config file and restore every package listed in the file to the global packages directory
        gci $src_directory -Recurse "packages.config" |% {
            $projectPackagesConfig = $_.FullName

            Write-Host "Restoring " $projectPackagesConfig
            . $nuget_exe_path\nuget.exe i $projectPackagesConfig -o $src_directory\packages

            Write-Host "Restoring " $projectPackagesConfig " from Artifactory - Teams"
            . $nuget_exe_path\nuget.exe i $projectPackagesConfig -o $src_directory\packages -Source http://artifactory-clt.devtms.local:8081/artifactory/api/nuget/teams-nuget-local

            #http://clt01d1afact01.devtms.local:8081/artifactory/api/nuget/teams-nuget-local
        }
    }

    Import-Module .\tools\psake.4.4.1\psake.psm1


    if ( $taskName -eq "" )
    {
      # Run pSake with no task name, this will display the available tasks
      Invoke-Psake .\_psakeBuild.ps1 -docs -nologo
  
      Write-Host "Please enter a task to run..."
      $taskName = Read-Host "="
    }

        Invoke-Psake .\_psakeBuild.ps1 $taskName -nologo -framework "4.0x64" #-properties @{ buildNumber=$buildNumber }
    Write-Host ""

    [bool]$buildSucceeded = $psake.build_success -eq $true

    Remove-Module psake

    if ($buildSucceeded) {
        exit 0
    }
    else {
        exit 1
    }


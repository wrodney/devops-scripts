Param(
    [string]$taskName,
    [switch]$packageRestore = $false,
    [string]$revision,
    [string]$buildConfig,
    [switch]$liveNuGet = $false
)

    $this_directory = Resolve-Path .
    $src_directory = Resolve-Path ..\source

    $global:buildMajor   = "0"
    $global:buildMinor   = "7"
    $global:buildRelease = "0"
    $global:buildNumber  = $revision
    $global:assemblyFileVersion = ""
    $global:assemblyVersion = ""

    $global:environmentName = $buildConfig

    # If a environment name was not passed in, default to "Debug"
    if ($environmentName -eq $null -Or $environmentName -eq "") {
        $global:environmentName = "Debug"
    }

    # If the build number was passed in, use that, otherwise use a text file on the machine to find the build number
    
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
    
    #
    $global:assemblyFileVersion="$global:buildMajor.$global:buildMinor.$global:buildRelease.$global:buildNumber"
    $global:assemblyVersion="$global:buildMajor.$global:buildMinor.0.0"
    $global:shortVersion="$global:buildMajor.$global:buildMinor"

    # If -liveNuGet switch is supplied, keep the beta string as ""
    $global:nugetBetaString = "";
    if ( $liveNuGet -eq $false ) {
       $global:nugetBetaString = "-beta";
    }

    # 
    if ( $packageRestore -eq $true ) {

        $nuget_exe_path = [System.IO.Path]::Combine($this_directory, "tools");

        # Find every packages.config file and restore every package listed in the file to the global packages directory
        gci $src_directory -Recurse "packages.config" |% {
            $projectPackagesConfig = $_.FullName
            Write-Host "Restoring " $projectPackagesConfig
            . $nuget_exe_path\nuget.exe i $projectPackagesConfig -o $src_directory\packages
        }
    }

    Import-Module .\tools\psake.4.4.1\psake.psm1

    # If $taskName was not passed in as an argument, then prompt for it
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
    

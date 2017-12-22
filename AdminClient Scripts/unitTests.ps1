properties {
}

task Run.UnitTests -description "Run all unit tests using nUnit" {

    $working_directory = "$base_directory\build\nunit"
    mkdir $working_directory -ea SilentlyContinue | Out-Null
    
    # Find every *.Test.csproj in the source
    [string]$testProjectPath = [System.IO.Path]::Combine($src_directory, "*.Tests.csproj")
    [array]$testProjectFiles = Get-ChildItem -Path $testProjectPath -Recurse | where {!$_.PsIsContainer}

    foreach ($testProjectFile in $testProjectFiles)
    {
        # C:\path\to\csproj
        [string]$testProjectFilePath = [System.IO.Path]::GetDirectoryName($testProjectFile)

        # Diligent.Teams.Test.csproj
        [string]$testProjectFileName = [System.IO.Path]::GetFileNameWithoutExtension($testProjectFile)

        # Diligent.Teams.Test.dll
        [string]$testProjectLibraryName = "$testProjectFileName.dll"

        # C:\path\to\library\bin\debug\Diligent.Teams.Test.dll
        [string]$testProjectLibraryPath = [System.IO.Path]::Combine($testProjectFilePath, "bin\$environmentName\$testProjectLibraryName")

        Write-Host -ForegroundColor Green "Found unit test project: $testProjectFileName"

        # If I can't find the .dll, then skip
        if (!(test-path $testProjectLibraryPath)) {
            continue;
        }

        # C:\tmp\build\Diligent.Teams.Test.xml
        $nunit_results_file = "$working_directory\$testProjectFileName.xml"

        Write-Host -ForegroundColor Green "Running unit tests for project: $testProjectFileName"

        . $nunit_console_exe /framework=net-4.5 /process=Multiple /domain=Multiple /timeout=10000 /nologo /nodots /stoponerror "$testProjectLibraryPath" /result="$nunit_results_file"
    }

}






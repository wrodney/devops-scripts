properties {
    $framework_version = "v4.5.2"

    $codeSolutions = @(
        @{Name = "Diligent.Teams.ClientAdminPortal.Mvc"; Sln = "$src_directory\Diligent.Teams.ClientAdminPortal.Mvc.sln"}
    )
}

$env:ProgramFiles = ${env:ProgramFiles(x86)}

task Clean -description "Clean all binary output" {

    foreach ($codeSolution in $codeSolutions)
    {
        Write-Host -ForegroundColor Green "Cleaning " $codeSolution.Name " - " $environmentName
        exec { msbuild /nologo /verbosity:q $codeSolution.Sln /p:Configuration=$environmentName /t:Clean }
    }
}

task UpdateVersion -description "Will create VersionAssemblyInfo.cs with version parameter" {
    
    $releaseVersionAssemblyInfoFile = "$src_directory/VersionAssemblyInfo.cs"

    $sb = New-Object -TypeName "System.Text.StringBuilder";
    
    [void]$sb.AppendLine("using System.Reflection;");
    [void]$sb.AppendLine("[assembly: AssemblyVersion(""$assemblyVersion"")]");
    [void]$sb.AppendLine("[assembly: AssemblyFileVersion(""$assemblyFileVersion"")]");

    $sb.ToString() > $releaseVersionAssemblyInfoFile
}

task Compile.Code -depends Clean,UpdateVersion -description "MSBuild all C# .sln" {
 
    Write-Host -ForegroundColor Green "Building all C# .sln with release $assemblyFileVersion"
 
    foreach ($codeSolution in $codeSolutions)
    {
        # For debugging, it is useful to clean right before compile.  This will ensure that any 
        # previously built solution isn't hiding issues with missing dependencies in a .sln
        #Write-Host -ForegroundColor Green "Cleaning " $codeSolution.Name " - " $environmentName
        #exec { msbuild /nologo /verbosity:q $codeSolution.Sln /p:Configuration=$environmentName /t:Clean }
            
        Write-Host -ForegroundColor Green "Building " $codeSolution.Name " - " $environmentName
        exec { msbuild /nologo /verbosity:q $codeSolution.Sln /p:Configuration=$environmentName /p:TargetFrameworkVersion=$framework_version }
    }
}


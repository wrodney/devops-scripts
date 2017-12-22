Param(
    [string]$buildConfig = "Debug",
        [string]$revision
	)

	$this_directory = Resolve-Path .
	$src_directory = Resolve-Path ..\source

	#Define the assembly version data
	$global:buildMajor   = "0"
	$global:buildMinor   = "5"
	$global:buildRelease = "0"

	#Create several variant version strings
	$global:assemblyFileVersion = "$global:buildMajor.$global:buildMinor.$global:buildRelease.$global:revision"
	$global:assemblyVersion = "$global:buildMajor.$global:buildMinor.0.0"
	$global:shortVersion="$global:buildMajor.$global:buildMinor"

	# Create a VersionAssemblyInfo so that any assembly can reference this
	$releaseVersionAssemblyInfoFile = "$src_directory/VersionAssemblyInfo.cs"
	$sb = New-Object -TypeName "System.Text.StringBuilder";

	[void]$sb.AppendLine("using System.Reflection;");
	[void]$sb.AppendLine("[assembly: AssemblyVersion(""$assemblyVersion"")]");
	[void]$sb.AppendLine("[assembly: AssemblyFileVersion(""$assemblyFileVersion"")]");

	$sb.ToString() > $releaseVersionAssemblyInfoFile


	# Clean up the packages directory
	if((Test-Path -Path $src_directory\packages))
	{
	     rm $src_directory\packages -r -Force
	}

    # Restore all nuget packages from every source
    & "$this_directory\tools\nuget.exe" restore $src_directory\Diligent.Teams.OfficeClient.sln
    & "$this_directory\tools\nuget.exe" restore $src_directory\Diligent.Teams.OfficeClient.sln -Source "http://artifactory-clt.devtms.local:8081/artifactory/api/nuget/research-nuget-local"
    & "$this_directory\tools\nuget.exe" restore $src_directory\Diligent.Teams.OfficeClient.sln -Source "http://artifactory-clt.devtms.local:8081/artifactory/api/nuget/teams-nuget-local"

    # Compile
    & "C:\windows\Microsoft.NET\Framework64\v4.0.30319\msbuild" $src_directory\Diligent.Teams.OfficeClient.sln /p:Configuration=$buildConfig /p:Platform="Any CPU" | Out-Null

    #
	     if ($LASTEXITCODE -gt 0)
     {
         write-output "Failed: msbuild of Diligent.Teams.OfficeClient.sln"
         exit $LASTEXITCODE 
		       }

	     if ($LASTEXITCODE -eq 0)
		       {
	      write-output "Success: clean exit from msbuild of Diligent.Teams.OfficeClient.sln"
			    } 

	 # Run unit tests
	 & "$this_directory\tools\nunit.2.6.4\nunit-console.exe" $src_directory\Desktop\ViewModelTests\Diligent.Teams.Diligent.Teams.OfficeClient.ViewModel.Tests.csproj /xml:ViewModel.Tests.Result.xml /config:$buildConfig  
	 & "$this_directory\tools\nunit.2.6.4\nunit-console.exe" $src_directory\Desktop\Common.Tests\Diligent.Teams.Common.Tests.csproj /xml:Common.Tests.Result.xml /config:$buildConfig  
	 & "$this_directory\tools\nunit.2.6.4\nunit-console.exe" $src_directory\Diligent.Teams.Domain.Tests\Diligent.Teams.Domain.Tests.csproj /xml:Domain.Tests.Result.xml /config:$buildConfig  

	 # Run Integration tests
	    if ($buildConfig -eq "DEV")
	  {
	   	& "$this_directory\tools\nunit.2.6.4\nunit-console.exe" $src_directory\Desktop\Tests\Diligent.Teams.Diligent.Teams.OfficeClient.Tests.csproj /xml:Integration.Tests.Result.xml /config:$buildConfig  
	  }

	# Zip up the binaries for now until a OneClient/ClickOnce structure is determined...
	  if(!(Test-Path -Path $this_directory\artifacts))
		{
		    mkdir $this_directory\artifacts
		}
		. $this_directory\tools\pkzipc.exe -add -rec -dir=relative "Artifacts\Desktop.zip" "$src_directory\Desktop\Application\bin\$buildConfig\*" #| Out-Null

   # Compile w/ Publish option to create .application files
     & "C:\windows\Microsoft.NET\Framework64\v4.0.30319\msbuild" $src_directory\Diligent.Teams.OfficeClient.sln /t:Publish /p:Configuration=$buildConfig /p:Platform="Any CPU" /p:BootstrapperEnabled=false | Out-Null

     # TODO: Copy all binaries and push to the deployment service...
     # Test for the type of build

     # Array of possible build configs and their cooresponding
     # machine names/paths

     $environments = @(      
         "DEV", 
	     "DEMO", 
         "STABLE", 
	     "QA"
						          
					  )
	  $buildconfigs = @{ BuildName = "DEV"; MachineName = "clt01d1app12.devtms.local"; DirectoryPath = "\\clt01d1app12.devtms.local\deploy\Research" },
   	                 @{ BuildName = "DEMO"; MachineName = "clt01d1web14.devtms.local"; DirectoryPath = "\\clt01d1web14.devtms.local\deploy\Research" },
	                @{ BuildName = "STABLE"; MachineName = "clt01d1web13.devtms.local"; DirectoryPath = "\\clt01d1web13.devtms.local\deploy\Research" },
	               @{ BuildName = "QA"; MachineName = "clt01d1app15.devtms.local"; DirectoryPath = "\\clt01d1app15.devtms.local\deploy\Research" };
												                
													     
    # NOTE: Will need to update the .application to update the deployment url xml element to the http endpoint the files are going to...


	# Copy the the build files to http://clt01d1web14.devtms.local:58200/application/Diligent.Teams.OfficeClient
	# NOTE: This will copy the Desktop.zip file to the remote machine.  We need to copy the files located here: \Source\Desktop\Application\bin\Debug\app.publish\*.


    # Find the DesktopClient machine in the hardware config 

       $selectedbuildconfigs = $buildconfigs | where {$_.buildname -eq "$buildconfig"} 

	# Copy the output of the Desktop
        . robocopy "$src_directory\Desktop\Application\bin\$buildConfig" "\\clt01d1web13.devtms.local\deploy\Diligent.Teams.OfficeClient" *.* /e /np /r:0

    # TODO: Also include the ClickOnce .application files...
    # Needs to get here:  http://clt01d1web14.devtms.local:58200/applications/

 <#
	 @{
       Name = "Services";
       Hardware = @(
       @{ BuildName = "DEV"; MachineName = "clt01d1app12.devtms.local"; DirectoryPath = "\\clt01d1app12.devtms.local\deploy\Research" },
       @{ BuildName = "DEMO"; MachineName = "clt01d1web14.devtms.local"; DirectoryPath = "\\clt01d1web14.devtms.local\deploy\Research" },
       @{ BuildName = "STABLE"; MachineName = "clt01d1web13.devtms.local"; DirectoryPath = "\\clt01d1web13.devtms.local\deploy\Research" },
       @{ BuildName = "QA"; MachineName = "clt01d1app15.devtms.local"; DirectoryPath = "\\clt01d1app15.devtms.local\deploy\Research" }
#>


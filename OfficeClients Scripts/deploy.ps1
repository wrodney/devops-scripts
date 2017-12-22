properties {
}

Task Deploy.Copy -description "Copy all applications to the research physical environment" {

    # 
    $sqlHardwareConfig = $hardwareConfig | where {$_.Name -eq "Sql"}
    $sqlHardware = $sqlHardwareConfig.Hardware | where {$_.BuildName -eq $environmentName}
    $sqlDirectoryPath = $sqlHardware.DirectoryPath

    # Copy .sql scripts and sql packages to the sql box
    . robocopy $sql_publish_path "$sqlDirectoryPath\$buildNumber" *.sql /e /np /r:0
    . robocopy $sql_publish_path "$sqlDirectoryPath\$buildNumber" *.spkg /e /np /r:0

    #
    foreach($hardwareConfigItem in $hardwareConfig) {

        # Find the hardware details based upon the current build environment
        $hardware = $hardwareConfigItem.Hardware | where {$_.BuildName -eq $environmentName}

        # Get the machine name and directory path to push installers to
        $directoryPath = $hardware.DirectoryPath
        $machineName = $hardware.MachineName

        foreach($app in $hardwareConfigItem.Apps) {

            $appFileName = $app.FileName

            echo $appFileName

            # Copy application to the server
            . robocopy $apps_publish_path "$directoryPath\$buildNumber\installers" $appFileName /e /np /r:0

            # TODO: Loop to the number of instances specified for the app and pass this into the .exe

            # FIX: PSEXEC will causes problems installing services without the current security context.  Require manual for now...
            # Run the install batch file on the machine
            #. psexec \\$machineName C:\deploy\_install.bat
        }
    }

}

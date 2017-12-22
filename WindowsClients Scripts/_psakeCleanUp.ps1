.SYNOPSIS
        A simple script that cleans and build visual studio solution with psake

    .DESCRIPTION
        Apsake is a simple build automation tool written in powershell, and works well on Microsoft platform.
        This is a really simple example that cleans bin folder, run msbuild to build the solution, and clean up pdb and xml files afterward. 
        
    .PARAMETER  <Parameter-Name>
        The description of a parameter. Add a .PARAMETER keyword for
        each parameter in the function or script syntax.

        Type the parameter name on the same line as the .PARAMETER keyword. 
        Type the parameter description on the lines following the .PARAMETER
        keyword. Windows PowerShell interprets all text between the .PARAMETER
        line and the next keyword or the end of the comment block as part of
        the parameter description. The description can include paragraph breaks.

        The Parameter keywords can appear in any order in the comment block, but
        the function or script syntax determines the order in which the parameters
        (and their descriptions) appear in help topic. To change the order,
        change the syntax.
 
        You can also specify a parameter description by placing a comment in the
        function or script syntax immediately before the parameter variable name.
        If you use both a syntax comment and a Parameter keyword, the description
        associated with the Parameter keyword is used, and the syntax comment is
        ignored.


properties {
    $BuildConfiguration = if ($BuildConfiguration -eq $null ) { "debug" } else {     
        $BuildConfiguration }
    $BuildScriptsPath = Resolve-Path .
    $base_dir = Resolve-Path ..
    $packages = "$base_dir\packages"
    $build_dir = "$base_dir\Sushiwa\bin"
    $sln_file = "$base_dir\Sushiwa.sln"
}
 
task default -depends CleanUp, Compile
 
task CleanUp {
    @($build_dir) | aWhere-Object { Test-Path $_ } | ForEach-Object {
    Write-Host "Cleaning folder $_..."
    Remove-Item $_ -Recurse -Force -ErrorAction Stop
    }
}
 
task Compile {
    Write-Host "Compiling $sln_file in $BuildConfiguration mode to $build_dir"
    Exec { msbuild "$sln_file" /t:Clean /t:Build /p:Configuration=$BuildConfiguration
        /m /nr:false /v:q /nologo /p:OutputDir=$build_dir }
 
    Get-ChildItem -Path $build_dir -Rec | Where {$_.Extension -match "pdb"} | Remove-Item
    Get-ChildItem -Path $build_dir -Rec | Where {$_.Extension -match "xml"} | Remove-Item
}

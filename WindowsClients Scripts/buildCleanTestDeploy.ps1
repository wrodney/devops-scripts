<#

A simple example of build automation for us (developers) could cover clean, build, tests and copying to release directory:


#>

$framework = '4.0'
$sln = 'c:\dev\.....sln'
$outDir = 'c:\dev\...'

task default -depends Rebuild,Test,Out
task Rebuild -depends Clean,Build
task Clean { 
  #exec { msbuild $slnPath '/t:Clean' }
  Write-Host Clean....
}
task Build { 
  #exec { msbuild $slnPath '/t:Build' }
  Write-Host Build....
}
task Test { 
  # run nunit console or whatever tool you want
  Write-Host Test....
}
task out {
  #gci somedir -include *.dll,*.config | copy-item -destination $outDir
  Write-Host Out....
}
Param(
[string]$newVersion
)

(Get-Content Source\Desktop\Application\Properties\AssemblyInfo.cs) | Out-String | 
Foreach-Object {$_ -replace '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}',$newVersion}  | 
Set-Content Source\Desktop\Application\Properties\AssemblyInfo.cs
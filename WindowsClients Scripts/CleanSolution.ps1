<#
PS C:\scripts> cleanBin C:\temp\SomeSolution

It will recursively look at every folder under your solution root and remove and bin or obj directories.  

The complete function definition is as follows:


#>

function cleanBin {
    param ([string]$path)
    
    write-host "Cleaning bin from: $path"
    get-childitem $path -include bin -recurse | remove-item
    
    write-host "Cleaning obj from: $path"
    get-childitem $path -include obj -recurse | remove-item
}
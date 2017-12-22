$username = "local_msolonkovich"
$password = "******************"
$FolderLocation = 'C:\Users\msolonkovich\Documents\Fonts' 



gci $FolderLocation -Recurse | ? {$_.PSiscontainer} | %{
    $filename = $($_.Name -replace '\\'.'/') + '/'
    $fullfilepath = ($_.FullName -replace [regex]::Escape($FolderLocation),'') -replace '\\','/'
    $ArtUrl = 'http://chc01q1afact01.msohosting.local:8081/artifactory/' + $ArtRepo  + $fullfilepath + '/'
    $webRequest = [System.Net.WebRequest]::Create($ArtUrl)
    $webRequest.ServicePoint.Expect100Continue = $false
    $webRequest.Credentials = New-Object System.Net.NetworkCredential -ArgumentList $username, $password
    $webRequest.PreAuthenticate = $true
    $webRequest.Method = "PUT"
    $webRequest.Headers.Add('repo', $ArtRepo)
    $webRequest.Headers.Add('path', $filename)
    $requestStream = $webRequest.GetRequestStream()
    $requestStream.Close()
    [System.Net.WebResponse]$resp = $webRequest.GetResponse();
    $rs = $resp.GetResponseStream();
    [System.IO.StreamReader]$sr = New-Object System.IO.StreamReader -argumentList $rs;
    [string]$results = $sr.ReadToEnd();
    return $results;
}



$cred = Get-Credential -UserName 'local_msolonkovich' -Message "Enter ArtCred"
gci $FolderLocation -Recurse -Include *.nupkg | ? {!($_.PSiscontainer)} | % {
    $filename = $_.Name
    $filepath = $_.FullName
    $fullfilepath = ($_.FullName -replace [regex]::Escape($FolderLocation),'') -replace '\\','/'
    $uri = 'http://chc01q1afact01.msohosting.local:8081/artifactory/' + $ArtRepo  + $fullfilepath 
    Start-Job -ScriptBlock {Invoke-RestMethod -Uri $using:uri -Method PUT -InFile $using:filePath -ContentType "multipart/form-data" -Credential $using:cred}
    $JobCount = ($(Get-Job).State | ? {$_ -match 'Running'}).count
    While ($JobCount -gt '25') {Sleep -Seconds 5; $JobCount = ($(Get-Job).State | ? {$_ -match 'Running'}).count}
    } 

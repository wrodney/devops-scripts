#PowerShell function to open the first .sln found recursively:

function sln($path = '.') {
$s = ls $path *.sln -Rec | select -First 1;
if($s) { start $s.FullName /D $s.DirectoryName }
}
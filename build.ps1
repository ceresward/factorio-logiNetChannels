# Powershell build script for Logistic Network Channels mod

param (
    [Parameter(Mandatory=$true)][string]$version
 )
$modname = "LogiNetChannels_$version"
Copy-Item -Path .\src -Recurse -Destination $modname -Container
Compress-Archive -Path $modname -DestinationPath "$modname.zip"
Remove-Item -Path $modname -Recurse
Move-Item -Path "$modname.zip" -Destination "zip"
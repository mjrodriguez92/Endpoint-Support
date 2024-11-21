<#PSScriptInfo

.VERSION 1.0

.AUTHOR Michael Rodriguez


.RELEASENOTES
Version 1.0:  Original published version.

<#
.SYNOPSIS
Installs the list of programs defined by their repository id via Winget.

.DESCRIPTION
This script retreives the repository packages based on the listed applications in the below array using the Winget package
installation utility. 

Please see the below link for the Microsoft learn documentation for Winget:
https://learn.microsoft.com/en-us/windows/package-manager/winget/

#>


$packages = @(
    "7zip.7zip",
    "Zoom.Zoom",
    "Zoom.ZoomOutlookPlugin",
    "Google.Chrome",
    "Citrix.Workspace",
    "Adobe.Acrobat.Reader.64-bit",
    "Microsoft.Office"
)

ForEach ($package in $packages) {
    Start-Process -FilePath "winget" -ArgumentList "install", "-e", "--accept-source-agreements", "--accept-package-agreements", "-q", $package -Wait
}


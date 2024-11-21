<#PSScriptInfo

.VERSION 1.0

.AUTHOR Michael Rodriguez


.RELEASENOTES
Version 1.0:  Original published version.
Version 1.1: Added PSScriptInfo Section

#>

<#
.SYNOPSIS
Retreives all the information related to importing endpoints into the Intune Autopilot repository.

.DESCRIPTION
This script retreives all the necessary data such as the device manufacturer, serial numer, and hardware hash
that is exported to csv to allow device imports into the Autopilot registered devices repository in Intune.

#>


New-Item -Type Directory -Path "C:\HWID"
Set-Location -Path "C:\HWID"
$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
Install-Script -Name Get-WindowsAutopilotInfo
Get-WindowsAutopilotInfo -OutputFile AutopilotHWID.csv
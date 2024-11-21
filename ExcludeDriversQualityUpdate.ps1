<#PSScriptInfo

.VERSION 1.0

.AUTHOR Michael Rodriguez


.RELEASENOTES
Version 1.0:  Original published version.

#>

<#
.SYNOPSIS
This registry modification will block drivers from being included in Windows Updates.

.DESCRIPTION
This script will make a modification to the ExcludeWUDriversInQualityUpdate key in the Windows registry to block drivers from
being included from regular Windows update checks. This can be done if you want to ensure that installed drivers and firmware
updates are being installed using manufacturer specific update utilities. This is often done with the Dell Command Update and 
Lenovo Commercial Vantage platforms to ensure all recommended drivers and firmware come directly from the manufacturer to
reduce the risk that Microsoft retreives an incorrect update that requires troubleshooting to resolve. This is often the 
case for display issues caused by Microsoft using their "Basic Display Adapter" instead of using the recommended display
driver and this will especially be an issue for devices using docking stations. 

#>


Start-Process powershell -WindowStyle Hidden -ArgumentList "-Command New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Force; Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name ExcludeWUDriversInQualityUpdate -Value 1 -Type DWord"


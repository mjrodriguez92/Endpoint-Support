<#PSScriptInfo

.VERSION 1.0

.AUTHOR Michael Rodriguez


.RELEASENOTES
Version 1.0:  Original published version.

.SYNOPSIS
Enables the WinHttpAutoProxy service.

.DESCRIPTION
This script makes a registry modification to enable the WinHttpAutoProxy service. This modification is 
often needed when vpn connections are having issues establishing and completing the connection to a 
vpn gateway. This troubleshooting step is commonly needed to resolve Cisco Anyconnect issues as recommended
by the Meraki Support team. 

#>

Start-Process powershell -WindowStyle Hidden -ArgumentList "-Command Set-ItemProperty -Path 'HKLM\SYSTEM\CurrentControlSet\Services\WinHttpAutoProxySvc' -Name Start -Value 3"


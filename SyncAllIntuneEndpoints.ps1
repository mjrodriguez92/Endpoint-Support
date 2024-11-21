<#PSScriptInfo

.VERSION 1.0

.AUTHOR Michael Rodriguez

.RELEASENOTES
Version 1.0:  Original published version.

.SYNOPSIS
Initiates a devices sync for all registered devices via Microsoft Graph Module(s).

.DESCRIPTION
This script utilizes the Microsoft Graph powershell module to reach Intune registered devices
and triggers each device to check-in with the Intune MDM service.

#>


#Intune SDK Graph Modules
Install-Module -Name Microsoft.Graph.DeviceManagement.Actions -Force  -AllowClobber
Install-Module -Name Microsoft.Graph.DeviceManagement -Force -AllowClobber
 
# Importing the SDK Module
Import-Module -Name Microsoft.Graph.DeviceManagement.Actions
 
Connect-MgGraph -scope DeviceManagementManagedDevices.PrivilegedOperations.All, DeviceManagementManagedDevices.ReadWrite.All,DeviceManagementManagedDevices.Read.All
 
#### Gets All devices
$Devices = Get-MgDeviceManagementManagedDevice -All
 
Foreach ($Device in $Devices)
{
 
Sync-MgDeviceManagementManagedDevice -ManagedDeviceId $Device.Id
 
Write-Host "Sending Sync request to Device with Device name $($Device.DeviceName)" -ForegroundColor Yellow
  
}
  
Disconnect-Graph
<#PSScriptInfo

.VERSION 1.0

.AUTHOR Michael Rodriguez


.RELEASENOTES
Version 1.0:  Original published version.

#>

<#
.SYNOPSIS
Retreives a list of all unhealthy endpoints from Microsoft Intune.

.DESCRIPTION
This script retreives all the requested data for unhealthy endpoints via an Azure automation runbook powershell script. 
This script will export a list of unhealthy Intune endpoints and email a csv of the report as an attactment to the listed
recipient(s).
resource rooms such as the resource names, allowed calendar conflicts, number of instances
allowed, and percentage even.

#>

# Set some variables
$ProgressPreference = 'SilentlyContinue'
$EmailParams = @{
    To         = 'recipient@contoso.com'
    From       = 'azureautomation@contoso.onmicrosoft.com'
    Smtpserver = 'contoso-com.mail.protection.outlook.com'
    Port       = 25
}

# Obtain an access token for MS Graph as a Managed Identity
$url = $env:IDENTITY_ENDPOINT  
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]" 
$headers.Add("X-IDENTITY-HEADER", $env:IDENTITY_HEADER) 
$headers.Add("Metadata", "True") 
$body = @{resource='https://graph.microsoft.com/' } 
$accessToken = (Invoke-RestMethod $url -Method 'POST' -Headers $headers -ContentType 'application/x-www-form-urlencoded' -Body $body ).access_token
$authHeader = @{
    'Authorization' = "Bearer $accessToken"
}

# Download data from MS Graph
$URI = "https://graph.microsoft.com/beta/deviceManagement/manageddevices?`$filter=StartsWith(operatingSystem,'Windows')&`$select=deviceName,enrolledDateTime,lastSyncDateTime,managementAgent,deviceEnrollmentType,userPrincipalName,model,serialNumber,userDisplayName,configurationManagerClientEnabledFeatures,configurationManagerClientHealthState"
$Response = Invoke-WebRequest -Uri $URI -Method Get -Headers $authHeader -UseBasicParsing 
$JsonResponse = $Response.Content | ConvertFrom-Json
$DeviceData = $JsonResponse.value
If ($JsonResponse.'@odata.nextLink')
{
    do {
        $URI = $JsonResponse.'@odata.nextLink'
        $Response = Invoke-WebRequest -Uri $URI -Method Get -Headers $authHeader -UseBasicParsing 
        $JsonResponse = $Response.Content | ConvertFrom-Json
        $DeviceData += $JsonResponse.value
    } until ($null -eq $JsonResponse.'@odata.nextLink')
}

# Organise the data as we want it displayed
$Devices = New-Object System.Collections.ArrayList
foreach ($item in $DeviceData)
{
    try {
        [void]$Devices.Add(
            [PSCustomObject]@{
                deviceName = $item.deviceName
                enrolledDateTime = $item.enrolledDateTime
                daysEnrolled = [math]::Round(((Get-Date) - ($item.enrolledDateTime | Get-Date -ErrorAction SilentlyContinue)).TotalDays,0)
                lastSyncDateTime = $item.lastSyncDateTime
                daysSinceLastSync = [math]::Round(((Get-Date) - ($item.lastSyncDateTime | Get-Date -ErrorAction SilentlyContinue)).TotalDays,0)
                managementAgent = $item.managementAgent
                deviceEnrollmentType = $item.deviceEnrollmentType
                userPrincipalName = $item.userPrincipalName
                model = $item.model
                serialNumber = $item.serialNumber
                userDisplayName = $item.userDisplayName
                memcmEnabledFeature_inventory = $item.configurationManagerClientEnabledFeatures.inventory
                memcmEnabledFeature_modernApps = $item.configurationManagerClientEnabledFeatures.modernApps
                memcmEnabledFeature_resourceAccess = $item.configurationManagerClientEnabledFeatures.resourceAccess
                memcmEnabledFeature_deviceConfiguration = $item.configurationManagerClientEnabledFeatures.deviceConfiguration 
                memcmEnabledFeature_compliancePolicy = $item.configurationManagerClientEnabledFeatures.compliancePolicy
                memcmEnabledFeature_windowsUpdateForBusiness = $item.configurationManagerClientEnabledFeatures.windowsUpdateForBusiness
                memcmEnabledFeature_endpointProtection = $item.configurationManagerClientEnabledFeatures.endpointProtection
                memcmEnabledFeature_officeApps = $item.configurationManagerClientEnabledFeatures.officeApps
                memcmClientHealth_state = $item.configurationManagerClientHealthState.state
                memcmClientHealth_errorCode = $item.configurationManagerClientHealthState.errorCode
                memcmClientHealth_lastSyncDateTime = $item.configurationManagerClientHealthState.lastSyncDateTime
                memcmClientHealth_daysSinceLastSync = [math]::Round(((Get-Date) - ($item.configurationManagerClientHealthState.lastSyncDateTime | Get-Date -ErrorAction SilentlyContinue)).TotalDays,0)
            }
        )
    }
    catch {} 
}

# Filter and export just the unhealthy clients - those that have talked to Intune but haven't talked to MEMCM in the last 7 days 
$UnhealthyMEMCMClients = $Devices | where {$_.memcmClientHealth_state -ne 'healthy' -and $_.daysSinceLastSync -le 7 -and $_.memcmClientHealth_daysSinceLastSync -gt 7}
$UnhealthyMEMCMClients | export-csv -Path $env:temp\UnhealthyMEMCMClients.csv -Force -NoTypeInformation 

# Send the email
Send-MailMessage @EmailParams -Subject "[Azure Automation] Unhealthy MEMCM Clients in Intune ($($UnhealthyMEMCMClients.Count))" -Attachments "$env:temp\UnhealthyMEMCMClients.csv"
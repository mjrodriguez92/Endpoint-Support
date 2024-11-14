<#/
This script will modify the value of the UpdateBranch key in the Windows registry
to set the update channel for O365 to current channel retrieving the latest 
O365 updates as soon as they're available.
/#>
# Define the registry path
$registryPath = "HKLM:\Software\Policies\Microsoft\office\16.0\common\officeupdate"

# Check if the registry path exists, if not create it
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Set the update channel to "Current"
Set-ItemProperty -Path $registryPath -Name "updatebranch" -Value "Current"

# Set the update deadline to 0 (immediate update enforcement)
Set-ItemProperty -Path $registryPath -Name "UpdateDeadline" -Value "0"

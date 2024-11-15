<#PSScriptInfo

.VERSION 1.0

.AUTHOR Michael Rodriguez


.RELEASENOTES
Version 1.0:  Original published version.

#>

<#
.SYNOPSIS
Retreives all the information related to calendar conflicts for an array of resource rooms

.DESCRIPTION
This script retreives all the requested data for what is permitted for an organizations 
resource rooms such as the resource names, allowed calendar conflicts, number of instances
allowed, and percentage even.

#>

# Array of all resource mailboxes
$identities = @(
)

# Exchange Online PowerShell module path
$powershell_module_path = "C:\Program Files\WindowsPowerShell\Modules\ExchangeOnlineManagement\3.1.0\ExchangeOnlineManagement.psd1"


# Import the Exchange Online PowerShell module
Import-Module -Name $powershell_module_path -Force

# Array to store the results
$results = @()

# Run Get-CalendarProcessing for each identity
foreach ($identity in $identities) {
    # Create the PowerShell command
    $command = "Get-CalendarProcessing -Identity $identity"
    
    # Run the PowerShell command and capture the output
    $output = Invoke-Command -ScriptBlock {param($cmd) Invoke-Expression $cmd } -ArgumentList $command
    
    # Extract desired properties from the CalendarConfiguration object
    $properties = @{
        DisplayName = $output.DisplayName
        Identity = $identity
        AutomateProcessing = $output.AutomateProcessing
        AllowConflicts = $output.AllowConflicts
        AllowRecurringMeetings = $output.AllowRecurringMeetings
        ConflictPercentageAllowed = $output.ConflictPercentageAllowed
        MaximumConflictInstances = $output.MaximumConflictInstances
        # Add more desired properties here
    }
    
    # Append the extracted properties to the results array
    $result = [PSCustomObject]$properties
    $results += $result
}

# Export the results to an Excel file
$results | Export-Csv -Path "C:\Users\MichaelRodriguez\Downloads\CalendarProcessingReport.csv" -NoTypeInformation

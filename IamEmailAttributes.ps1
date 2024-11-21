[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)][string]$SamAccountName,
    [Parameter(Mandatory=$true)][string]$EmailAddress,
    [Parameter(Mandatory=$false)][PSCredential]$Credential,
    [Parameter(Mandatory=$false)][string]$LogFile = "C:\Logs\ADUserUpdate.log"
)

# Define a function for logging
function Write-Log {
    param (
        [Parameter(Mandatory=$true)][string]$Message,
        [Parameter(Mandatory=$true)][ValidateSet('INFO', 'WARNING', 'ERROR')][string]$Level = 'INFO',
        [Parameter(Mandatory=$false)][switch]$WriteToConsole
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp [$Level] $Message"
    
    # Write to log file
    Add-Content -Path $LogFile -Value $logMessage
    
    # Optionally write to console
    if ($WriteToConsole) {
        Write-Output $logMessage
    }
}

# Start script execution logging
Write-Log -Message "Starting AD user update for $SamAccountName" -Level 'INFO' -WriteToConsole

try {
    # Import Active Directory module if not already imported
    if (-not (Get-Module -Name ActiveDirectory -ErrorAction SilentlyContinue)) {
        Write-Log -Message "Importing Active Directory module" -Level 'INFO' -WriteToConsole
        Import-Module ActiveDirectory -ErrorAction Stop
    }

    # Extract mail nickname from email address
    $mailNickname = ($EmailAddress -split '@')[0]

    # Define common attributes for the AD user update
    $replaceAttributes = @{
        mail                        = $EmailAddress
        msExchPoliciesExcluded      = '<exchange policy GUID goes here>'
        msExchRemoteRecipientType   = '4'
        msExchRecipientDisplayType  = '-2147483642'
        msExchRecipientTypeDetails  = '2147483648'
        msExchVersion               = '88218628259840'
        targetaddress               = "smtp:$SamAccountName@<domain goes here>"
        mailnickname                = $mailNickname
    }

    # Define proxy addresses
    $proxyAddresses = @(
        "SMTP:$EmailAddress",
        "smtp:$SamAccountName@<domain goes here>",
        "smtp:$SamAccountName@exch.<domain goes here>"
    )

    # Construct splat for Set-ADUser command
    $splat = @{
        Identity = $SamAccountName
        Server   = <servername goes here>
        Replace  = $replaceAttributes
        Add      = @{ proxyAddresses = $proxyAddresses }
    }

    if ($Credential) {
        $splat.Credential = $Credential
    }

    # Update the AD user
    Write-Log -Message "Updating AD user: $SamAccountName" -Level 'INFO' -WriteToConsole
    Set-ADUser @splat -ErrorAction Stop

    Write-Log -Message "AD user update for $SamAccountName completed successfully." -Level 'INFO' -WriteToConsole
}
catch {
    $errorMessage = "Error updating AD user $SamAccountName: $_"
    Write-Log -Message $errorMessage -Level 'ERROR' -WriteToConsole
    throw # Re-throw the error if you want the script to fail after logging
}

# End script execution logging
Write-Log -Message "Script execution completed for $SamAccountName" -Level 'INFO' -WriteToConsole

#Shows Archive Status For All Users
Get-Mailbox -ResultSize unlimited | Select DisplayName, @{Label="ArchiveStatus";
Expression={
    if($_.ArchiveStatus -eq "Active" -OR $_.ArchiveDatabase -ne $null) {
    "Enabled"}else {"Disabled"
    }
        }
            };
    
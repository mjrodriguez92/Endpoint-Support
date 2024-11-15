<#PSScriptInfo

.VERSION 1.0

.AUTHOR Michael Rodriguez


.RELEASENOTES
Version 1.0:  Original published version.

#>

<#
.SYNOPSIS
Retreives a detailed report of end-user archive data.

.DESCRIPTION
This script gets a list of all end users with active mailbox archives and outputs information in a report
containing data such as user displaynames, upn, archive status, their mailbox size, archive quota, etc. 
This report will be exported and saved to the set file name & path listed at the end of execution.

#>


$Result = @()
$mailboxes = Get-Mailbox -ResultSize Unlimited
$totalmbx = $mailboxes.Count
$i = 0

foreach ($mbx in $mailboxes) {
    $i++
    Write-Progress -Activity "Processing $($mbx.DisplayName)" -Status "Processing mailbox $i out of $totalmbx" -PercentComplete (($i / $totalmbx) * 100)

    $size = 0
    if ($mbx.ArchiveStatus -eq "Active") {
        $mbs = Get-MailboxStatistics $mbx.UserPrincipalName
        if ($mbs -and $mbs.TotalItemSize) {
            $size = [math]::Round(($mbs.TotalItemSize.ToString().Split('(')[1].Split(' ')[0].Replace(',','') / 1MB), 2)
        }
    }

    $archiveWarningQuota = if ($mbx.ArchiveStatus -eq "Active") { $mbx.ArchiveWarningQuota }
    $archiveQuota = if ($mbx.ArchiveStatus -eq "Active") { $mbx.ArchiveQuota }

    $resultObj = [PSCustomObject]@{
        UserName = $mbx.DisplayName
        UserPrincipalName = $mbx.UserPrincipalName
        ArchiveStatus = $mbx.ArchiveStatus
        ArchiveName = $mbx.ArchiveName
        ArchiveState = $mbx.ArchiveState
        ArchiveMailboxSizeInMB = $size
        ArchiveWarningQuota = $archiveWarningQuota
        ArchiveQuota = $archiveQuota
        AutoExpandingArchiveEnabled = $mbx.AutoExpandingArchiveEnabled
    }
    $Result += $resultObj
}

$Result | Export-CSV "C:\temp\Archive-Mailbox-Report.csv" -NoTypeInformation -Encoding UTF8

<#PSScriptInfo

.VERSION 1.0

.AUTHOR Michael Rodriguez


.RELEASENOTES
Version 1.0:  Original published version.

.SYNOPSIS
Adds mailbox folder permissions for end users in an array.

.DESCRIPTION
This script takes the first array of end users, identified by their SMTP addresses, and adds the desired permissions
to their exchange accounts to the end user accounts identified in the second array. 

#>

# Define the mailbox target (calendar owner)
$users = @(
)

# Define the users who will have rights to view or edit the mailbox target's calendar
$users2 = @(
)

# Loop through each calendar owner
ForEach ($user in $users) {
    # Loop through each user to give permissions
    ForEach ($user2 in $users2) {
        # Set permissions for each user on each calendar without confirmation prompts
        Add-MailboxFolderPermission -Identity $user -User $user2 -AccessRights Editor -Confirm:$false
    }

    # Output the permissions to verify correct application
    Get-MailboxFolderPermission -Identity $user | Format-List Identity, FolderName, User, AccessRights
}

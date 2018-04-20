# Script to grant access rights on mailboxes
#

# Mailboxes to grant rights on
$grantRightsOnMailboxes = @('','')

# Users to grant rights to
$grantRightsToUsers = @('','')

# Rights to grant
$accessRights = 'Editor'

# Get Office 365 Credentials
$credential = Get-Credential

# Establish a session to Exchange Online
$credential = Get-Credential -Message 'Enter your Exchange Online administrator credentials'
$connectionParams = @{
    'ConfigurationName' = 'Microsoft.Exchange';
    'ConnectionUri' = 'https://outlook.office365.com/powershell-liveid/';
    'Credential' = $credential;
    'Authentication' = 'Basic';
    'AllowRedirection' = $true
} 
$exchangeSession = New-PSSession @connectionParams
Import-PSSession -Session $exchangeSession

# Apply the permissions
foreach ($grantRightsToUser in $grantRightsToUsers ) {
    foreach ($grantRightsOnMailbox in $grantRightsOnMailboxes) {
        $calendarIdentity = $grantRightsOnMailbox + ':\Calendar'
        $existingPermissions = Get-MailboxFolderPermission -Identity $calendarIdentity -User $grantRightsToUser -ErrorAction SilentlyContinue
        if (!($existingPermissions)) {
            Add-MailboxFolderPermission -Identity $calendarIdentity -User $grantRightsToUser -AccessRights $accessRights
        }
        else {
            Set-MailboxFolderPermission -Identity $calendarIdentity -User $grantRightsToUser -AccessRights $accessRights
        }
        Set-Mailbox -Identity $upn –GrantSendOnBehalfTo @{add=$editor}
    }
}

# End the PowerShell session
Remove-PSSession -Session $exchangeSession

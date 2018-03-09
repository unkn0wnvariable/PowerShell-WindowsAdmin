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

# Connect to Exchange Online
$sessionOptions = New-PSSessionOption -ProxyAccessType IEConfig
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri 'https://outlook.office365.com/powershell-liveid/' -Credential $credential -Authentication Basic -AllowRedirection -SessionOption $sessionOptions
Import-PSSession $exchangeSession

# Apply the permissions
ForEach ($grantRightsToUser in $grantRightsToUsers ) {
    ForEach ($grantRightsOnMailbox in $grantRightsOnMailboxes) {
        $calendarIdentity = $grantRightsOnMailbox + ':\Calendar'
        $existingPermissions = Get-MailboxFolderPermission -Identity $calendarIdentity -User $grantRightsToUser -ErrorAction SilentlyContinue
        If (!($existingPermissions)) {
            Add-MailboxFolderPermission -Identity $calendarIdentity -User $grantRightsToUser -AccessRights $accessRights
        }
        Else {
            Set-MailboxFolderPermission -Identity $calendarIdentity -User $grantRightsToUser -AccessRights $accessRights
        }
        Set-Mailbox -Identity $upn –GrantSendOnBehalfTo @{add=$editor}
    }
}

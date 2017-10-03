
# Set up some variables

$grantRightsOnMailboxes = @('','')

$grantRightsToUsers = @('','')

$accessRights = "Editor"


# Get Office 365 Credentials

$credential = Get-Credential


# Connect to Exchange Online

$sessionOptions = New-PSSessionOption -ProxyAccessType IEConfig
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri 'https://outlook.office365.com/powershell-liveid/' -Credential $credential -Authentication Basic -AllowRedirection -SessionOption $sessionOptions
Import-PSSession $exchangeSession


# Apply the permissions

ForEach ($grantRightsToUser in $grantRightsToUsers ) {
    ForEach ($grantRightsOnMailbox in $grantRightsOnMailboxes) {
        $existingPermissions = Get-MailboxFolderPermission -Identity $grantRightsOnMailbox":\Calendar" -User $grantRightsToUser -ErrorAction SilentlyContinue
        If (!($existingPermissions)) {
            Add-MailboxFolderPermission -Identity $grantRightsOnMailbox":\Calendar" -User $grantRightsToUser -AccessRights $accessRights
        }
        Else {
            Set-MailboxFolderPermission -Identity $grantRightsOnMailbox":\Calendar" -User $grantRightsToUser -AccessRights $accessRights
        }
        Set-Mailbox -Identity $upn –GrantSendOnBehalfTo @{add=$editor}
    }
}

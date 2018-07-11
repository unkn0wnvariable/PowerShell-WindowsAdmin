# Script to get all client forwarding rules, smtp forwarding rules and delegates on mailboxes
#
# This builds on top of a script from https://github.com/OfficeDev/O365-InvestigationTooling
#

# Establish a session to Exchange Online
$credentials = Get-Credential -Message 'Enter your Exchange Online administrator credentials'
$connectionParams = @{
    'ConfigurationName' = 'Microsoft.Exchange';
    'ConnectionUri' = 'https://outlook.office365.com/powershell-liveid/';
    'Credential' = $credentials;
    'Authentication' = 'Basic';
    'AllowRedirection' = $true
} 
$exchangeSession = New-PSSession @connectionParams
Import-PSSession -Session $exchangeSession

$allUsers = @()
$allUsers = Get-Mailbox -ResultSize Unlimited | Select-Object DisplayName,UserPrincipalName,ForwardingAddress,ForwardingSMTPAddress,DeliverToMailboxandForward

$userInboxRules = @()
$userDelegates = @()

foreach ($user in $allUsers) {
    Write-Progress -Activity "Checking inbox rules for..." -status $user.UserPrincipalName -percentComplete ($allUsers.IndexOf($user) / $allUsers.Count * 100)
    $userInboxRules += Get-InboxRule -Mailbox $user.UserPrincipalName | `
        Select-Object MailboxOwnerId,Name,Description,Enabled,Priority,ForwardTo,ForwardAsAttachmentTo,RedirectTo,DeleteMessage | `
        Where-Object {($_.ForwardTo -ne $null) -or ($_.ForwardAsAttachmentTo -ne $null) -or ($_.RedirectsTo -ne $null)}
    $userDelegates += Get-MailboxPermission -Identity $user.UserPrincipalName | Where-Object {($_.IsInherited -ne "True") -and ($_.User -notlike "*SELF*")}
}

$smtpForwarding = $allUsers | Select-Object DisplayName,ForwardingAddress,ForwardingSMTPAddress,DeliverToMailboxandForward | Where-Object {$_.ForwardingSMTPAddress -ne $null}

$userInboxRules | Export-Csv MailForwardingRulesToExternalDomains.csv -NoTypeInformation
$smtpForwarding | Export-Csv Mailboxsmtpforwarding.csv -NoTypeInformation
$userDelegates | Export-Csv MailboxDelegatePermissions.csv -NoTypeInformation

Remove-PSSession -Session $exchangeSession

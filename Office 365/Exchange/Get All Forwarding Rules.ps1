# Script to get all client forwarding rules, smtp forwarding rules and delegates on mailboxes
#
# This builds on top of a script from https://github.com/OfficeDev/O365-InvestigationTooling
#

$AdminCreds = Get-Credential

$EOLSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $AdminCreds -Authentication Basic -AllowRedirection
Import-PSSession -Session $EOLSession

$AllUsers = @()
$AllUsers = Get-Mailbox -ResultSize Unlimited | Select-Object DisplayName,UserPrincipalName,ForwardingAddress,ForwardingSMTPAddress,DeliverToMailboxandForward

$UserInboxRules = @()
$UserDelegates = @()

foreach ($User in $AllUsers) {
    Write-Progress -Activity "Checking inbox rules for..." -status $User.UserPrincipalName -percentComplete ($AllUsers.IndexOf($User) / $AllUsers.Count * 100)
    $UserInboxRules += Get-InboxRule -Mailbox $User.UserPrincipalName | Select-Object MailboxOwnerId,Name,Description,Enabled,Priority,ForwardTo,ForwardAsAttachmentTo,RedirectTo,DeleteMessage | Where-Object {($_.ForwardTo -ne $null) -or ($_.ForwardAsAttachmentTo -ne $null) -or ($_.RedirectsTo -ne $null)}
    $UserDelegates += Get-MailboxPermission -Identity $User.UserPrincipalName | Where-Object {($_.IsInherited -ne "True") -and ($_.User -notlike "*SELF*")}
}

$SMTPForwarding = $AllUsers | Select-Object DisplayName,ForwardingAddress,ForwardingSMTPAddress,DeliverToMailboxandForward | Where-Object {$_.ForwardingSMTPAddress -ne $null}

$UserInboxRules | Export-Csv MailForwardingRulesToExternalDomains.csv -NoTypeInformation
$SMTPForwarding | Export-Csv Mailboxsmtpforwarding.csv -NoTypeInformation
$UserDelegates | Export-Csv MailboxDelegatePermissions.csv -NoTypeInformation

Remove-PSSession -Session $EOLSession

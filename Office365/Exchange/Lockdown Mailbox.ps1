# Enable mailbox auditing and disable PowerShell remoting on individual mailboxes
#
# Working on this as a one stop for hardening Exchange Online accounts
#

# UPN of New User
$newUPN = ''

# Is the user an administrator?
$isAnAdmin = $false

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

# Set Auditing parameters
$params = @{
	'AuditEnabled' = $true
	'AuditLogAgeLimit' = '180'
	'AuditAdmin' = @('Update','MoveToDeletedItems','SoftDelete','HardDelete','SendAs','SendOnBehalf','Create','UpdateFolderPermission')
	'AuditDelegate' = @('Update','SoftDelete','HardDelete','SendAs','Create','UpdateFolderPermissions','MoveToDeletedItems','SendOnBehalf')
	'AuditOwner' = @('UpdateFolderPermission','MailboxLogin','Create','SoftDelete','HardDelete','Update','MoveToDeletedItems')
}

# Enable Auditing
Get-Mailbox -Identity $newUPN | Set-Mailbox @params

# Disable PowerShell Remoting for non-Admin staff
if ($isAnAdmin) {
	Set-User -Identity $newUPN -RemotePowerShellEnabled $true
}
else {
	Set-User -Identity $newUPN -RemotePowerShellEnabled $false
}

# Disconnect from Exchange Online
Remove-PSSession $exchangeSession

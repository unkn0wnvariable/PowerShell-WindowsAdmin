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

# Connect to Exchange Online
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credential -Authentication Basic -AllowRedirection
Import-PSSession $exchangeSession

# Set Auditing parameters
$params = @{
	'AuditEnabled' = $true
	'AuditLogAgeLimit' = '180'
	'AuditAdmin' = @('Update','MoveToDeletedItems','SoftDelete','HardDelete','SendAs','SendOnBehalf','Create','UpdateFolderPermission')
	'AuditDelegate' = @('Update','SoftDelete','HardDelete','SendAs','Create','UpdateFolderPermissions','MoveToDeletedItems','SendOnBehalf')
	'AuditOwner' = @('UpdateFolderPermission','MailboxLogin','Create','SoftDelete','HardDelete','Update','MoveToDeletedItems')
}

# Enable Auditing
Get-Mailbox -Identity $newUPN | Set-Mailbox @params -WhatIf

# Disable PowerShell Remoting for non-Admin staff
If ($isAnAdmin) {
	Set-User -Identity $newUPN -RemotePowerShellEnabled $true
}
Else {
	Set-User -Identity $newUPN -RemotePowerShellEnabled $false
}

# Disconnect from Exchange Online
Remove-PSSession $exchangeSession

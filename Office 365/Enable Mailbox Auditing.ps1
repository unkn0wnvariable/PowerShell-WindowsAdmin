# Enable mailbox auditing on mailboxes where auditing is not already enabled
#
# This is a rewrite of a script from https://github.com/OfficeDev/O365-InvestigationTooling
#

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
Get-Mailbox -ResultSize Unlimited | Where-Object {$_.RecipientTypeDetails -match '(User|Shared|Room|Discovery)Mailbox' -and $_.AuditEnabled -eq $false} | Set-Mailbox @params

# Disconnect from Exchange Online
Remove-PSSession $exchangeSession

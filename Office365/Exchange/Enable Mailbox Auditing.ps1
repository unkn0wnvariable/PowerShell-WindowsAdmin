# Enable mailbox auditing on mailboxes where auditing is not already enabled
#
# This is a rewrite of a script from https://github.com/OfficeDev/O365-InvestigationTooling
#

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
Get-Mailbox -ResultSize Unlimited | Where-Object {$_.RecipientTypeDetails -match '(User|Shared|Room|Discovery)Mailbox' -and $_.AuditEnabled -eq $false} | Set-Mailbox @params

# Check Auditing
Get-Mailbox -ResultSize Unlimited | Select-Object UserPrincipalName,RecipientTypeDetails,AuditEnabled,AuditLogAgeLimit | Format-Table -AutoSize

# Disconnect from Exchange Online
Remove-PSSession $exchangeSession

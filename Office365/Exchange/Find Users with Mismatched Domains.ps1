# Find mailboxes where UPN domain doesn't match email domain
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

# Get list of mailboxes with a different mail domain to UPN domain
Get-Mailbox -ResultSize Unlimited | Where-Object {$_.UserPrincipalName.Split('@')[1] -ne $_.PrimarySmtpAddress.Split('@')[1]} | Format-Table Name,UserPrincipalName,PrimarySmtpAddress,RecipientTypeDetails

# Disconnect from Exchange Online
Remove-PSSession $exchangeSession

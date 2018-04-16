# Find mailboxes where UPN domain doesn't match email domain
#

# Get Office 365 Credentials
$credential = Get-Credential

# Connect to Exchange Online
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credential -Authentication Basic -AllowRedirection
Import-PSSession $exchangeSession

# Get list of mailboxes with a different mail domain to UPN domain
Get-Mailbox -ResultSize Unlimited | Where-Object {$_.UserPrincipalName.Split('@')[1] -ne $_.PrimarySmtpAddress.Split('@')[1]} | Format-Table Name,UserPrincipalName,PrimarySmtpAddress,RecipientTypeDetails

# Disconnect from Exchange Online
Remove-PSSession $exchangeSession

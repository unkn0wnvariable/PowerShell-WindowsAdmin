# Script to get all accounts from AD that have no UPN set, and output to a CSV file
#

# Where to save the output file?
$outputPath = 'C:\Temp\AccountsWithoutUPN.csv'

# Get domain controller name and credentials for connecting to AD
$adServer = Read-Host -Prompt 'Enter the FQDN of a domain controller'
$adCredentials = Get-Credential -Message 'Enter credentials for an account with the necessary permissions'

# Import the AD module
Import-Module ActiveDirectory

# List of properties to retrieve
$adProperties = @(
    'DisplayName',
    'SamAccountName',
    'UserPrincipalName',
    'EmailAddress',
    'Company',
    'Department',
    'Title',
    'Office',
    'CanonicalName',
    'Enabled',
    'ObjectGUID',
    'Created',
    'LastLogonDate'
)

# Find all accounts with a 0 length UPN (empty field)
$discoveredAccounts = Get-ADUser -Server $adServer -Credential $adCredentials -Filter * -Properties $adProperties | Where-Object -FilterScript { $_.UserPrincipalName.Length -eq 0 } | Select-Object -Property $adProperties

# Output results to grid view
$discoveredAccounts | Export-Csv -Path $outputPath -NoTypeInformation

# A script to get a list of all accounts in windows AD with their password set to never expire
# and output that list, with some other information, to a CSV file
#

# Path for the CSV file to be output
$outputPath = 'C:\Temp\non-expiring_passwords.csv'

# Get domain controller name and credentials for connecting to AD
$serverDetails = @{
    Server     = Read-Host -Prompt 'Enter the FQDN of a domain controller'
    Credential = Get-Credential -Message 'Enter credentials for an account with the necessary permissions'
}

# Import the AD module
Import-Module -Name ActiveDirectory

# The properties to retrive from AD and include in the output
$includedProperties = @(
    'Name',
    'UserPrincipalName',
    'Enabled',
    'PasswordNeverExpires',
    'CannotChangePassword',
    'PasswordLastSet',
    'ObjectClass',
    'CanonicalName'
)

# Get all the account from AD with non-expiring password, where the account also requires a password
$nonExpiringUsers = Get-ADUser -Filter 'PasswordNeverExpires -eq "true" -and PasswordNotRequired -eq "false"' -Properties $includedProperties @serverDetails

# Output the list of user to a CSV file
$nonExpiringUsers | Select-Object $includedProperties | Export-CSV -Path $outputPath -NoTypeInformation

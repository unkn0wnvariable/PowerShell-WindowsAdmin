# Script to get all accounts in Active Directory where adminCount is not 0
#

# Where to save the output file?
$outputPath = 'C:\Temp\AdminAccounts.csv'

# Get domain controller name and credentials for connecting to AD
$adServer = Read-Host -Prompt 'Enter the FQDN of a domain controller'
$adCredentials = Get-Credential -Message 'Enter credentials for an account with the necessary permissions'

# Import the AD module
Import-Module ActiveDirectory

# Properties to be included in output file
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

# adminCount is required, so if it's not in the list above add it on
$adminCountAdded = $false
if ('adminCount' -notin $adProperties) {
    [System.Collections.ArrayList]$adProperties = @($adProperties)
    [void]$adProperties.Add('adminCount')
    $adminCountAdded = $true
}

# Get all user accounts where adminCount is greater than 0
$adminAccounts = Get-ADUser -Server $adServer -Credential $adCredentials -Filter * -Properties $adProperties | Where-Object -FilterScript { $_.adminCount -gt 0 } | Select-Object -Property $adProperties

# If adminCount wasn't included in the original properties list, remove it again for output
if ($adminCountAdded) {
    [void]$adProperties.Remove('adminCount')
}

# Export results to CSV
$adminAccounts | Select-Object -Property $adProperties | Export-Csv -Path $outputPath -NoTypeInformation

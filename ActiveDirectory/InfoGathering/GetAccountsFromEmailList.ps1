# Find account details from a list of email addresses
#

# Import the Active Directory module
Import-Module -Name ActiveDirectory

# Get domain controller name and credentials for connecting to AD
$serverDetails = @{
    Server     = Read-Host -Prompt 'Enter the FQDN of a domain controller'
    Credential = Get-Credential -Message 'Enter credentials for an account with the necessary permissions'
}

# Set input and output file paths
$dataFolder = 'C:\Temp\'
$emailsListFile = 'EmailAddresses.txt'
$outputFile = 'UserDetails.csv'

# Get the list of email addresses from the text file
$emailsList = Get-Content -Path ($dataFolder + $emailsListFile)

# Get all enabled users from AD, where the password is not set to never expire, password hasn't expired and an email address is present (to send the alert to)
$propertiesList = @(
    'GivenName'
    'Surname'
    'Name'
    'SamAccountName'
    'EmailAddress'
    'UserPrincipalName'
    'Enabled'
    'Created'
    'pwdLastSet'
    'PasswordExpired'
    'PasswordNeverExpires'
    'DistinguishedName'
    'ObjectClass'
    'ObjectGUID'
)

# Get the coresponding accounts from Active Directory
$users = Get-ADUser @serverDetails -Filter { Enabled -eq $true } -Properties $propertiesList | `
    Where-Object { $_.EmailAddress -in $emailsList } | `
    Select-Object -Property $propertiesList

# Create anew object for output data
$usersDetails = New-Object System.Collections.ArrayList

# Run through the accounts and add them to the output object
foreach ($user in $users) {
    try {
        $passwordLastSet = [datetime]::FromFileTime($user.pwdLastSet)
    }
    catch {
        $passwordLastSet = '0'
    }

    [void]$usersDetails.Add(
        [PSCustomObject]@{
            GivenName            = $user.GivenName
            Surname              = $user.Surname
            DisplayName          = $user.Name
            SamAccountName       = $user.SamAccountName
            EmailAddress         = $user.EmailAddress
            UserPrincipalName    = $user.UserPrincipalName
            Enabled              = $user.Enabled
            Created              = $user.Created
            PasswordLastSet      = $passwordLastSet
            PasswordExpired      = $user.PasswordExpired
            PasswordNeverExpires = $user.PasswordNeverExpires
            DistinguishedName    = $user.DistinguishedName
            ObjectClass          = $user.ObjectClass
            ObjectGUID           = $user.ObjectGUID
        }
    )
}

# Export the results to a CSV file
$usersDetails | Export-Csv -Path ($dataFolder + $outputFile) -NoTypeInformation

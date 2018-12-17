# Bulk change the UPN of users in Active Directory
#

# What is the current UPN domain?
$oldUPNDomain = ''

# What are we changing the UPN domain to?
$newUPNDomain = ''

# Import the Active Directory module
Import-Module -Name ActiveDirectory

# Get administrative level credentials for Active Directory
$adCredentials = Get-Credential -Message 'Enter your Active Directory administrator credentials'

# Get all those accounts
$accountsToChange = Get-ADUser -Filter * | Where-Object {$_.UserPrincipalName -match $oldUPNDomain}

# Iterate through the accounts changing the UPN to the new domain
foreach ($accountToChange in $accountsToChange) {
    $newAccountUPN = $accountToChange.UserPrincipalName.Split('@')[0] + '@' + $newUPNDomain
    Write-Output -InputObject ('Updating UPN for account ' + $accountToChange.UserPrincipalName + ' to ' + $newAccountUPN)
    Set-ADUser -Identity $accountToChange.DistinguishedName -UserPrincipalName $newAccountUPN -Credential $adCredentials
}

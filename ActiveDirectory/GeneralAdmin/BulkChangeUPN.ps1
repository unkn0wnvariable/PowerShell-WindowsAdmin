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

# Extablish a search wildcard to find the accounts we need to change
$searchWildcard = '*@' + $oldUPNDomain

# Get all those accounts
$accountsToChange = Get-ADUser -Filter * | Where-Object {$_.UserPrincipalName -like $searchWildcard}

# Iterate through the accounts changing the UPN to the new domain
foreach ($accountToChange in $accountsToChange) {
    $newAccountUPN = $accountToChange.UserPrincipalName.Split('@')[0] + '@' + $newUPNDomain
    Set-ADUser -Identity $accountToChange -UserPrincipalName $newAccountUPN -Credential $adCredentials -WhatIf
}

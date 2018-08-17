# Find User accounts where UPN doesn't match the primary email address
#

## WORK IN PROGRESS ##

# Import ActiveDirectory module
Import-Module ActiveDirectory

# Get admin credentials for Active Directory
if ($null -eq $adminCredentials) {$adminCredentials = Get-Credential}

# Get a list of possible UPN suffixes from the forest
$upnSuffixes = (Get-ADForest).Domains
$upnSuffixes += (Get-ADForest).UPNSuffixes

$users = Get-ADUser -Filter '(enabled -eq $true) -and (EmailAddress -like "*")' -Properties EmailAddress,userPrincipalName,SamAccountName,enabled -Credential $adminCredentials

$output = @()

Foreach ($user in $users) {
    If (($user.EmailAddress.Split('@')[1] -in $upnSuffixes) -and ($user.SamAccountName -notmatch $user.EmailAddress.Split('@')[0])) {
    $output += $user.Name + ',' + $user.SamAccountName + ',' + $user.EmailAddress
    }
}

$output | Format-Table

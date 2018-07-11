# Update Online User UPN - when AD sync doesn't do it.

Import-Module MSOnline
Connect-MsolService

$oldUPN = Read-Host -Prompt 'Enter user''s old UPN in the format username@domain'
$newUPN = Read-Host -Prompt 'Enter user''s new UPN in the format username@domain'

if (Get-ADUser -Identity $newUPN.Split('@')[0]) {
    Set-MsolUserPrincipalName -UserPrincipalName $oldUPN -NewUserPrincipalName $newUPN
}

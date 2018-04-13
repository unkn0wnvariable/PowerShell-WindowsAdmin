# Delete a User and then delete the deleted user

Import-Module MSOnline
Connect-MsolService

$UPNToDelete = ''

Remove-MsolUser -UserPrincipalName $UPNToDelete
Remove-MsolUser -UserPrincipalName $UPNToDelete -RemoveFromRecycleBin

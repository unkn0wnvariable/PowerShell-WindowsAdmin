# Delete a user and then delete the deleted user

Import-Module MSOnline
Connect-MsolService

$UPNToDelete = Read-Host -Prompt 'Enter UPN of user to delete in the format username@domain'

Remove-MsolUser -UserPrincipalName $UPNToDelete
Remove-MsolUser -UserPrincipalName $UPNToDelete -RemoveFromRecycleBin

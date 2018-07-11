# Delete a user and then delete the deleted user

Import-Module MSOnline
Connect-MsolService

$upnToDelete = Read-Host -Prompt 'Enter UPN of user to delete in the format username@domain'

Remove-MsolUser -UserPrincipalName $upnToDelete
Remove-MsolUser -UserPrincipalName $upnToDelete -RemoveFromRecycleBin

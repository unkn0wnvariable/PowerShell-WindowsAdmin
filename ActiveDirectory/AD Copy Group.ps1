
$credentials = Get-Credential -Message 'Enter administrator credentials.'

$sourceGroup = Read-Host -Prompt 'Enter name of source group.'
$destinationGroup = Read-Host -Prompt 'Enter name of destination group.'

$users = Get-ADGroupMember -Identity $sourceGroup -Credential $credentials

$startCount = (Get-ADGroupMember -Identity $destinationGroup).Count
$newMembersCount = $users.Count

foreach ($user in $users) {
    Add-ADGroupMember -Identity $destinationGroup -Members $user.distinguishedname -Credential $credentials
}

$endCount = (Get-ADGroupMember -Identity $destinationGroup).Count

$newCount = $endCount - $startCount

"$newMembersCount users should have been added to group $destinationGroup"
"$newCount users have been added to group $destinationGroup"

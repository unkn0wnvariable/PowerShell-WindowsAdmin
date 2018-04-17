
$Credentials = Get-Credential -Message 'Enter administrator credentials.'

$SourceGroup = Read-Host -Prompt 'Enter name of source group.'
$DestinationGroup = Read-Host -Prompt 'Enter name of destination group.'

$Users = Get-ADGroupMember -Identity $SourceGroup -Credential $Credentials

$StartCount = (Get-ADGroupMember -Identity $DestinationGroup).Count
$NewMembersCount = $Users.Count

foreach ($User in $Users) {
    Add-ADGroupMember -Identity $DestinationGroup -Members $User.distinguishedname -Credential $Credentials
}

$EndCount = (Get-ADGroupMember -Identity $DestinationGroup).Count

$NewCount = $EndCount - $StartCount

"$NewMembersCount users should have been added to group $DestinationGroup"
"$NewCount users have been added to group $DestinationGroup"

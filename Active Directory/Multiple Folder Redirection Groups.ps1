$primaryGroup = "Folder Redirection OneDrive for Business"

$secondaryGroupWildcard = "Folder Redirection*"


$primaryMembers = (Get-ADGroupMember -Identity $primaryGroup).SamAccountName

$groupList = (Get-ADGroup -Filter {Name -like $secondaryGroupWildcard}).Name

Write-Host 'In addition to' $primaryGroup 'the following people are also in...'
ForEach ($secondaryGroup in $groupList) {
    If ($secondaryGroup -ne $primaryGroup) {
        $secondaryMembers = Get-ADGroupMember -Identity $secondaryGroup
        ForEach ($member in $secondaryMembers) {
            If ($member.SamAccountName -in $primaryMembers) {
                Write-Host $member.Name 'is in' $secondaryGroup
                #Remove-ADGroupMember -Identity $secondaryGroup -Members $member.SamAccountName -WhatIf
            }
        }
    }
}

# Script to sync the members of 2 groups in Active Directory
#

$group1Name = ''
$group2Name = ''

$credentials = Get-Credential

$group1Members = Get-ADGroupMember -Identity 'SIS Corporate WiFi'
$group2Members = Get-ADGroupMember -Identity 'Corporate WiFi'

$groupDifference = Compare-Object -ReferenceObject $group1Members -DifferenceObject $group2Members

ForEach ($member in $groupDifference) {
    Switch ($member.SideIndicator)
    {
        '=>' { Add-ADGroupMember -Identity $group1Name -Members $member.InputObject.distinguishedName -Credential $credentials }
        '<=' { Add-ADGroupMember -Identity $group2Name -Members $member.InputObject.distinguishedName -Credential $credentials }
    }
}

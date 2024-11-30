# Script to get the group memberships for a list of users
#

#Get the list of users from file
$userList = Get-Content -Path 'C:\Temp\UserList.txt'

# Create hash table to store the groups in
$emailEnabledGroups = @()

# Run through the users in the list getting mail enabled groups they are a member of
foreach ($user in $userList) {
    Write-Output -InputObject ('Getting group membership for ' + $user)
    $userGroups = (Get-ADUser $user -Properties MemberOf).MemberOf
    foreach ($userGroup in $userGroups) {
        $groupDetails = Get-ADGroup -Identity $userGroup -Properties mail
        if ($groupDetails.mail.Length -gt 0) {
            $emailEnabledGroups += $groupDetails
        }
    }    
}

# Remove all the duplicates from the list of groups
$uniqueGroups = $emailEnabledGroups | Sort-Object -Unique

# Create a new hash table to store the group details in
$groupDetails = @()

# Run through each group getting the details, create a new object for each one and add it to the hash table
foreach ($group in $uniqueGroups) {
    $groupMembers = (Get-ADGroupMember -Identity $group | Where-Object {$_.SamAccountName -in $userList}).SamAccountName -join '; '
    $groupDetails += [PSCustomObject]@{
        'GroupName' = $group.Name;
        'GroupEmail' = $group.mail;
        'GroupType' = $group.GroupCategory;
        'GroupMembers' = $groupMembers
    }
}

# Output the hash table to a CSV file.
$groupDetails | Export-Csv -Path 'C:\Temp\DistributionGroupMemberships.csv' -NoTypeInformation

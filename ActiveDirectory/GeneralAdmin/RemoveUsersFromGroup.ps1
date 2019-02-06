# Script to bulk remove users from a group
#

# What group are we removing people from?
$groupName = ''

# Where is the list of users to remove?
$userListPath = 'C:\Temp\UserList.txt'

# Import the Active Directory module
Import-Module -Name ActiveDirectory

# Get administrative level credentials for Active Directory
$adCredentials = Get-Credential -Message 'Enter your Active Directory administrator credentials'

# Get users from list
$userList = Get-Content -Path $userListPath

# Get existing groups members
$groupMembers = (Get-ADGroupMember -Identity $groupName -Credential $adCredentials).SamAccountName

# Remove alias from each mailbox
foreach ($user in $userList) {
    if ($user -in $groupMembers) {
        Write-Output -InputObject ('Remove user ' + $user + ' from group ' + $groupName + '.')
        Remove-ADGroupMember -Identity $groupName -Members $user -Credential $adCredentials -Confirm:$false
    }
}

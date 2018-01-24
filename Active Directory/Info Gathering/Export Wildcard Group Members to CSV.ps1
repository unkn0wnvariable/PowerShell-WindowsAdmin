# Script to pull all members of AD groups that begin with the name "Folder Redirection"
# and output them to a CSV file with account name, full name  and which group they were in.
#
# Cmdlets used require the ADDS component from RSAT to be installed.

# Where to save the output file?
# E.g.: $outputFile = 'C:\Temp\Folder Redirection Group Members.csv'

$outputFile = 'C:\Temp\Folder Redirection Group Members.csv'

# Wildcard string for the group names?
# E.g.: $groupWildcard = 'Folder Redirection*'

$groupWildcard = 'Folder Redirection*'


# Set up the CSV file and write out column headers

$headers = 'Username,Full Name,Member of Group'
Out-File -FilePath $outputFile -Encoding utf8 -Force
Write-Output -InputObject $headers | Out-File -FilePath $outputFile -Encoding utf8 -Force

# Load the Active Directory module

Import-Module ActiveDirectory

# Find all groups beginning with "Folder Redirection"

$groups = Get-ADGroup -Filter {Name -like $groupWildcard} | Sort-Object

# Iterate through the groups finding their members and writing them out to the CSV file

ForEach ($group in $groups) {
    $groupMembers = Get-ADGroupMember -Identity $group | Sort-Object
    ForEach ($groupMember in $groupMembers) {
        $output = $groupMember.SamAccountName + ',' + $groupMember.Name + ',' + $group.Name
        Write-Output -InputObject $output | Out-File -FilePath $outputFile -Encoding utf8 -Append
    }
}

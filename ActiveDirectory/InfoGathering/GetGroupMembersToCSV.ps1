# A simple script to get the members for a list of groups and output them to a bunch of CSV files

# What groups are we getting the members for?
$groups = @('')

# Get the members and save them to CSV files
foreach ($group in $groups) {
    Get-ADGroupMember -Identity $group | Export-Csv -Path ('C:\Temp\' + $group + '.csv') -NoTypeInformation
}

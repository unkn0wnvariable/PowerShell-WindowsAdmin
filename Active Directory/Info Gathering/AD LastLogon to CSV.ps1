# Script to retrieve last logon times for all user accounts in AD and save them to CSV
#
# Requires the Active Directory module from RSAT
#

# Import Active Directory PowerShell module
Import-Module ActiveDirectory

# Set location of output CSV file
$outputFile = 'C:\Temp\LastLogons.csv'

# Open output file
Out-File $outputFile -Encoding utf8 -Force

# Create table header row in output file
$tableHeader = 'Name,Account Name,Email Address,Last Logon Date,Last Logon Time'
Write-Output $tableHeader | Out-File $outputFile -Encoding utf8 -Append

# Get list of enabled users from AD
$users = Get-ADUser -Filter '(enabled -eq $true)' -Properties lastLogon,mail

# Iterate through users retriving the last logon time date and time, writing them out to file as we go
foreach ($user in $users) {
    $lastLogonDate = [datetime]::FromFileTime($user.lastLogon).ToString('dd/MM/yyyy')
    $lastLogonTime = [datetime]::FromFileTime($user.lastLogon).ToString('HH:mm:ss')

    $output = $user.Name + ',' + $user.SamAccountName + ',' + $user.mail + ',' + $lastLogonDate + ',' + $lastLogonTime

    Write-Output $output | Out-File $outputFile -Encoding utf8 -Append
}

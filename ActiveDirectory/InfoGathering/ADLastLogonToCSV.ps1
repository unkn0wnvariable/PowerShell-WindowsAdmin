# Script to retrieve last logon times for all user accounts in AD and save them to CSV
#
# Requires the Active Directory module from RSAT
#

# Import Active Directory PowerShell module
Import-Module ActiveDirectory

# Set location of output CSV file
$outputFile = 'C:\Temp\LastLogons.csv'

# Get list of enabled users from AD
$users = Get-ADUser -Filter '(enabled -eq $true)' -Properties lastLogon, mail | Select-Object Name, SamAccountName, Mail, @{N = 'LastLogonDate'; E = { [DateTime]::FromFileTime($_.lastLogon).ToString('dd/MM/yyyy') } }, @{N = 'LastLogonTime'; E = { [DateTime]::FromFileTime($_.lastLogon).ToString('HH:mm:ss') } }

# Output to CSV
$users | Export-Csv -Path $outputFile -NoTypeInformation

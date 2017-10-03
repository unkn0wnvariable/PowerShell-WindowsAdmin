# Simple load and connect MSOL PS module

Import-Module MSOnline
Connect-MsolService -Credential (Get-Credential)

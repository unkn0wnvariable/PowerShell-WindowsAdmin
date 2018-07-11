# Export a list of empty AD groups to CSV file

Get-ADGroup -Filter * -Properties Name,Members,CanonicalName,GroupCategory,GroupScope,Description | Where-Object {$_.Members.Count -eq '0'} | Select-Object Name,CanonicalName,GroupCategory,GroupScope,Description | Export-Csv C:\Temp\EmptyGroups.csv -NoTypeInformation

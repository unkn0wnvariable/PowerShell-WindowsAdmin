# Get list of all computers from AD and output to CSV

Get-ADComputer -Filter * -Properties Name,OperatingSystem,IPv4Address,Enabled,Created,LastLogonDate,CanonicalName | Select-Object Name,OperatingSystem,IPv4Address,Enabled,Created,LastLogonDate,CanonicalName | Export-Csv -Path 'C:\Temp\ADComputers.csv' -NoTypeInformation

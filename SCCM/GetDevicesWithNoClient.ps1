# Export two CSV files containing servers and workstations which are not in a managed state within SCCM
#
# Requires the SCCM admin console to be installed for the PowerShell module
#

# What is the name of the SCCM site?
$siteName = ''

# Where to save the files to?
$unmanagedServersFile = 'C:\Temp\UnmanagedServers.csv'
$unmanagedWorkstationsFile = 'C:\Temp\UnmanagedWorkstations.csv'

# Import the SCCM Module
Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)

# Switch to the site path
$sitePath = $siteName + ':'
Set-Location -Path $sitePath

# Find all unmanaged servers and workstations
$unmanagedServers = Get-CMDevice | Where-Object {$_.DeviceOS -like '*Windows*Server*' -and $_.IsClient -eq $false} | Select-Object Name,DeviceOS,ADSiteName,Status
$unmanagedWorkstations = Get-CMDevice | Where-Object {$_.DeviceOS -like '*Windows*Workstation*' -and $_.IsClient -eq $false} | Select-Object Name,DeviceOS,ADSiteName,Status

# Export unmanaged servers and workstations to CSV files
$unmanagedServers | Export-Csv -Path $unmanagedServersFile -NoTypeInformation
$unmanagedWorkstations | Export-Csv -Path $unmanagedWorkstationsFile -NoTypeInformation

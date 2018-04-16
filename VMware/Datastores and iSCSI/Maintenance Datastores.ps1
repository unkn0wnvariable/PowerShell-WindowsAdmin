# Script to get a count and list of datastores which are in maintenance mode
#
# Updated for PowerCLI 10
#

# Import the PowerCLI Module
Import-Module -Name VMware.PowerCLI -Force

#Get Credentials
$viCredential = Get-Credential -Message 'Enter credentials for VMware connection'

# Connect to the vSphere server
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'
Connect-VIServer -Server $viServer -Credential $viCredential

# Get Datastores in Maintenance Mode
$maintenanceStores = Get-Datastore -Server $viServer | Where-Object {$_.State -eq 'Maintenance'} | Select-Object Name,@{N='CanonicalName';E={$_.ExtensionData.Info.Vmfs.Extent[0].DiskName}},CapacityGB,FreeSpaceGB,State

#How many were there?
Write-Host ('There are ' + $maintenanceStores.Count + ' datastores in maintenance mode.')

# Display table of results
$maintenanceStores | Export-Csv -Path 'C:\Temp\MaintenanceDatastores.csv' -NoTypeInformation

# Output the naa numbers to a file for later use
$maintenanceStores.CanonicalName | Out-File -FilePath 'C:\Temp\MaintenanceDatastoreNaas.txt'

# Output the names to a file for later use
$maintenanceStores.Name | Out-File -FilePath 'C:\Temp\MaintenanceDatastoreNames.txt'

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

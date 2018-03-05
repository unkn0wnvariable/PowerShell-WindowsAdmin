# Script to get a count and list of datastores which are in maintenance mode
#

# Load the stuff we need
.'C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'

#Get Admin Credentials
$adminCreds = Get-Credential -Message 'Enter account details with admin rights to VMware'

# Connect to the vSphere server
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'
Connect-VIServer -Server $viServer -Credential $adminCreds

# Get Datastores in Maintenance Mode
$maintenanceStores = Get-Datastore -Server $viServer | Where-Object {$_.State -eq 'Maintenance'} | Select-Object Name,@{N='CanonicalName';E={$_.ExtensionData.Info.Vmfs.Extent[0].DiskName}},CapacityGB,FreeSpaceGB,State

#How many were there?
Write-Host ('There are ' + $maintenanceStores.Count + ' datastores in maintenance mode.')

# Display table of results
$maintenanceStores | Format-Table -AutoSize

# Output the naa numbers to a file for later use
$maintenanceStores.CanonicalName | Out-File -FilePath 'C:\Temp\MaintenanceDatastoreNaas.txt'

# Output the names to a file for later use
$maintenanceStores.Name | Out-File -FilePath 'C:\Temp\MaintenanceDatastoreNames.txt'

# Disconnect to the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

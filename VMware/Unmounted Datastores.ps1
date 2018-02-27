# Script to get a count and list of datastores which are in unmounted
#

# Load the stuff we need
.'C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'

# Connect to the vSphere server
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'
Connect-VIServer -Server $viServer

# Get Datastores in Maintenance Mode
$unmountedStores = Get-Datastore -Server $viServer | Where-Object {$_.State -eq 'Unavailable'} | Select-Object Name,@{N='CanonicalName';E={$_.ExtensionData.Info.Vmfs.Extent[0].DiskName}},CapacityGB,FreeSpaceGB,State

#How many were there?
Write-Host ('There are ' + $unmountedStores.Count + ' unmounted datastores.')

# Display table of results
$unmountedStores | Format-Table -AutoSize

# Output the naa numbers to a file for later use
$unmountedStores.CanonicalName | Out-File -FilePath 'C:\Temp\UmountedDatastoreNaas.txt'

# Output the names to a file for later use
$unmountedStores.Name | Out-File -FilePath 'C:\Temp\UmountedDatastoreNames.txt'

# Disconnect to the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

# Script to bulk disable storage IO on datastores
#

# Load the stuff we need
.'C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'

# Connect to the vSphere server
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'
Connect-VIServer -Server $viServer

# Get Datastores list from file
$datastoresList = Get-Content -Path 'C:\Temp\DatastoresToRemoveNames.txt'

# Disable storeage IO on datastores
Set-Datastore -Datastore $datastoresList -Server $viServer -StorageIOControlEnabled:$false -Confirm:$false

# Disconnect to the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

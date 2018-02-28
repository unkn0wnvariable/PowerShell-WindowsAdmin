# Preperations for removing datastores from vSphere
#

# Load the stuff we need
.'C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'

# Get Credentials
$vmCreds = Get-Credential -Message 'Enter credentials with the necessary permissions level.'

# Connect to the vSphere server
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'
Connect-VIServer -Server $viServer -Credential $vmCreds

# Name of temporary folder to use during deletion
$deletedFolder = 'Datastores to be Deleted'

# Get the list of datastores to work on
$datastoresList = Get-Content 'C:\Temp\DatastoresToRemoveNames.txt'

# Create folder to move datastores into
New-Folder -Name $deletedFolder -Server $viServer -Location datastore

# Take datastores out of maintenance mode
Set-Datastore -Datastore $datastoresList -Server $viServer -MaintenanceMode:$false -Confirm:$false

# Move datastores into folder
Move-Datastore -Datastore $datastoresList -Server $viServer -Destination $deletedFolder -Confirm:$false

# Disable storage IO on datastores
Set-Datastore -Datastore $datastoresList -Server $viServer -StorageIOControlEnabled:$false -Confirm:$false

# Now go to vSphere and unmount through the GUI.

# Disconnect to the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

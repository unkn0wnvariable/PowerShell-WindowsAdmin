# Preperations for removing datastores from vSphere
#
# Updated for PowerCLI 10
#

# Get Credentials
$viCredential = Get-Credential -Message 'Enter credentials for VMware connection'

# Get vSphere server name
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'

# Import the PowerCLI Module and Connect
Import-Module -Name VMware.PowerCLI -Force
Connect-VIServer -Server $viServer -Credential $viCredential

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

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

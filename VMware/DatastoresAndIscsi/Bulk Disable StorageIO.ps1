# Script to bulk disable storage IO on datastores
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

# Get Datastores list from file
$datastoresList = Get-Content -Path 'C:\Temp\DatastoresToRemoveNames.txt'

# Disable storeage IO on datastores
Set-Datastore -Datastore $datastoresList -Server $viServer -StorageIOControlEnabled:$false -Confirm:$false

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

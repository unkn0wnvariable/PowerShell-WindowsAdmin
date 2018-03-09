# Script to bulk disable storage IO on datastores
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

# Get Datastores list from file
$datastoresList = Get-Content -Path 'C:\Temp\DatastoresToRemoveNames.txt'

# Disable storeage IO on datastores
Set-Datastore -Datastore $datastoresList -Server $viServer -StorageIOControlEnabled:$false -Confirm:$false

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

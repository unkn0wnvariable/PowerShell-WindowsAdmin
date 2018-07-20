# Script to get a list of all powered on VM's from the specified vCenter server
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

# Disable HA on All Clusters
Get-Cluster -Server $viServer | Set-Cluster -HAEnabled:$false -Confirm:$false

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

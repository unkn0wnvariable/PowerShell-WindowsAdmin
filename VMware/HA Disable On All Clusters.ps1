# Script to get a list of all powered on VM's from the specified vCenter server
#
# Updated for PowerCLI 10
#

# Import the PowerCLI Module
Import-Module -Name VMware.PowerCLI -Force -DisableNameChecking

#Get Credentials
$viCredential = Get-Credential -Message 'Enter credentials for VMware connection'

# Connect to the vSphere server
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'
Connect-VIServer -Server $viServer -Credential $viCredential

# Enable HA on All Clusters
Get-Cluster -Server $viServer | Set-Cluster -HAEnabled:$false -Confirm:$false

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

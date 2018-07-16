# Script to find a VM by it's MAC address
#
# Created for PowerCLI 10
#

# Get Credentials
$viCredential = Get-Credential -Message 'Enter credentials for VMware connection'

# Get vSphere server name
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'

# Import the PowerCLI Module and Connect
Import-Module -Name VMware.PowerCLI -Force
Connect-VIServer -Server $viServer -Credential $viCredential

# What MAC Address are we looking for?
$macAddress = ''

# Get all VM's then get all the network adapters for the VMs and find the one with the right MAC address
$vm = Get-VM | Get-NetworkAdapter | Where-Object {$_.MacAddress -eq $macAddress}

# Output the parent VM of the network adapter
Write-Output -InputObject $vm.Parent

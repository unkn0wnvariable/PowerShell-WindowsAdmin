# Script to clean up records of detached LUNs from ESXi hosts
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

# Iterate through the hosts getting list of detached LUNs and removing them
ForEach ($esxHost in (Get-VMHost -Server $viServer)) { 
    $esxCli = Get-EsxCli -VMHost $esxHost -Server $viServer -V2
    $detachedUIDs = ($esxCli.storage.core.device.detached.list.Invoke()).DeviceUID
    ForEach($detachedUID in $detachedUIDs) {
        Write-Host ('Removing ' + $detachedUID + ' from ' + $esxHost.Name + '.')
        $esxCli.storage.core.device.detached.remove.Invoke(@{device = $detachedUID})
    }
}

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

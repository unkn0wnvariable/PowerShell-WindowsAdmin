# Script to clean up records of detached LUNs from ESXi hosts
#
#
# NOTE:
# This is somewhat important on ESXi 5, since if you don't remove these entries the hosts will
# slowly dissapear up their own rectums trying to find LUNs that shouldn't be attached.
#
# It's like no-one at VMware considered that we might need to remove storage at some point.
#


# Initialise PowerCLI Environment
.'C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'

#Get Admin Credentials
$adminCreds = Get-Credential -Message 'Enter account details with admin rights to VMware'

# Connect to the vSphere server
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'
Connect-VIServer -Server $viServer -Credential $adminCreds

# Iterate through the hosts getting list of detached LUNs and removing them
ForEach ($esxHost in (Get-VMHost -Server $viServer)) { 
    $esxCli = Get-EsxCli -VMHost $esxHost -Server $viServer -V2
    $detachedUIDs = ($esxCli.storage.core.device.detached.list.Invoke()).DeviceUID

    ForEach($detachedUID in $detachedUIDs) {
        $esxCli.storage.core.device.detached.remove.Invoke(@{device = $detachedUID})
    }
}

# Disconnect vCenter
Disconnect-VIServer -Server $viServer -Confirm:$false

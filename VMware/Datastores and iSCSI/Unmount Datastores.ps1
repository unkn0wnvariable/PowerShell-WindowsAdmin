# Script to unmount a list of datastores from the hosts in vSphere to which they are attached
#
# Updated for PowerCLI 10
#

<#
Please note:

The way this works it doesn't carry out any of the pre-unmount checks that umounting through the GUI does,
it is also much slower than using the GUI as it can only unmount from one host at a time, whereas the GUI
unmounts from all hosts in parallel.

To take datastores out of maintenance mode, remove them from clusters and disable storage I/O control
use the Datastore Unmount Prep.ps1 script.

To ensure datastores are OK to remove, first use the Datastore Unmount Checks.ps1 script.
#>

# Get Credentials
$viCredential = Get-Credential -Message 'Enter credentials for VMware connection'

# Get vSphere server name
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'

# Import the PowerCLI Module and Connect
Import-Module -Name VMware.PowerCLI -Force
Connect-VIServer -Server $viServer -Credential $viCredential

# Get list of datastores to detach from file
$datastoreNames = Get-Content -Path "C:\Temp\DatastoresToRemoveNames.txt"

# Iterate through the datastores to be unmounted...
foreach($datastoreName in $datastoreNames) {
    # Get the Uuid name for the datastore
    $datastore = Get-Datastore -Name $datastoreName
    $datastoreUuid = $datastore.ExtensionData.Info.Vmfs.Uuid

    # Which hosts is the datastore attached to?
    $attachedHosts = $datastore.ExtensionData.Host

    # Iterate through attached hosts unmounting the datastore
    foreach ($attachedHost in $attachedHosts) {
        # What's going on?
        Write-Host "Unmounting $datastoreName from $vmHost."

        # Open a connection to the VMware Storage System and detach the LUN from the host using the UUID
        $vmHost = Get-VMHost -Id $attachedHost.Key
        $vmStorage = Get-View $vmHost.Extensiondata.ConfigManager.StorageSystem
        $vmStorage.UnmountVmfsVolume($datastoreUuid)
    }
}

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

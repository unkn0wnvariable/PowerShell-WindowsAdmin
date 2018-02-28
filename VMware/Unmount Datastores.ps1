# Script to unmount a list of datastores the hosts in vSphere to which they are attached
#
# The way this works it doesn't carry out any of the preunmount checks that umounting through the GUI does,
# it is also much slower than using the GUI as it can only unmount from one host at a time, whereas the GUI
# unmounts from all hosts in parallel.
#
# To ensure datastores are OK to remove, first use the Datastore Unmount Prep.ps1 script.
#

# Load the stuff we need
.'C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'

# Connect to the vSphere server
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'
Connect-VIServer -Server $viServer

# Get list of datastores to detach from file
$datastoreNames = Get-Content -Path "C:\Temp\DatastoresToRemove.txt"

# Get all hosts attached to vSphere server
$vmHosts = Get-VMHost

# Iterate through the datastores to be unmounted...
ForEach($datastoreName in $datastoreNames) {
    # Get the Uuid name for the datastore
    $datastore = Get-Datastore -Name $datastoreName
    $datastoreUuid = $datastore.ExtensionData.Info.Vmfs.Uuid

    # Which hosts is the datastore attached to?
    $attachedHosts = $datastore.ExtensionData.Host

    # Iterate through attached hosts unmounting the datastore
    ForEach ($attachedHost in $attachedHosts) {
        # What's going on?
        Write-Host "Unmounting $datastoreName from $vmHost."

        # Open a connection to the VMware Storage System and detach the LUN from the host using the UUID
        $vmHost = Get-VMHost -Id $attachedHost.Key
        $vmStorage = Get-View $vmHost.Extensiondata.ConfigManager.StorageSystem
        $vmStorage.UnmountVmfsVolume($datastoreUuid)
    }
}

# Disconnect to the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

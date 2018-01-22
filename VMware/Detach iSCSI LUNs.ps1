# Script to detach a list of datastores and their underlying LUNs from all the hosts in vSphere

# Load the stuff we need
Add-PSSnapin VMware.VimAutomation.Core -ea "SilentlyContinue"
Add-PSSnapin VMware.VimAutomation.Vds -ea "SilentlyContinue"

.'C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'

# Connect to the vSphere server
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'
Connect-VIServer -Server $viServer

# Get list of datastores to detach from file
$datastoreNames = Get-Content -Path "C:\Temp\Datastores to Detach.txt"

# Get all hosts attached to vSphere server
$vmHosts = Get-VMHost

# Iterate through the hosts...
Foreach($vmHost in $vmHosts)
{
    # Iterate through the datastores to be removed...
    Foreach($datastoreName in $datastoreNames)
    {
        # Get the NAA name for the datastore
        $datastoreNaa = (Get-Datastore -Name $datastoreName | Select-Object @{N="DiskName";E={$_.ExtensionData.Info.Vmfs.Extent.DiskName}}).DiskName

        # Use the ID from above to get the UUID of the iSCSI LUN
        $lunUuid = (Get-ScsiLun -VmHost $vmHost -CanonicalName $datastoreNaa).ExtensionData.Uuid

        # What's going on?
        Write-Host "Detaching $lunUuid from $vmHost."

        # Open a connection to the VMware Storage System and detach the LUN from the host using the UUID
        #$vmStorage = Get-View $vmHost.Extensiondata.ConfigManager.StorageSystem
        #$vmStorage.DetachScsiLun($lunUuid)
    }
}

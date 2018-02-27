# Script to detach a list of non-datastore iSCSI LUNs from all the hosts in vSphere using their naa numbers
#
# This script is for detaching unused LUNs, i.e. those which show up in the "add storage" list.

# Load the stuff we need
.'C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'

# Connect to the vSphere server
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'
Connect-VIServer -Server $viServer

# Get list of datastores to detach from file
$datastoreNaas = Get-Content -Path "C:\Temp\UmountedDatastoreNaas.txt"

# Get all hosts attached to vSphere server
$vmHosts = Get-VMHost

# Iterate through the hosts...
Foreach($vmHost in $vmHosts)
{
    # Iterate through the datastores to be removed...
    Foreach($datastoreNaa in $datastoreNaas)
    {
        # What's going on?
        Write-Host "Detaching LUN $datastoreNaa from $vmHost... " -NoNewline

        # Use the ID from above to get the UUID of the iSCSI LUN
        $lunUuid = $null
        $lunUuid = (Get-ScsiLun -VmHost $vmHost -CanonicalName $datastoreNaa -ErrorAction SilentlyContinue).ExtensionData.Uuid

        If ($lunUuid -ne $null){
            # Open a connection to the VMware Storage System and detach the LUN from the host using the UUID
            $vmStorage = Get-View $vmHost.Extensiondata.ConfigManager.StorageSystem
            $vmStorage.DetachScsiLun($lunUuid)

            Write-Host "Completed." -ForegroundColor Green
        }
        Else {
            Write-Host "Not attached." -ForegroundColor Red
        }
    }
}

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer

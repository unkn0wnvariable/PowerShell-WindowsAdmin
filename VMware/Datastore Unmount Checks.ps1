# Script to replicate the checks that vSphere does when unmounting a datastore through the GUI
#
# I originally wrote this to integrate into a script to unmount the datastores through PowerCLI, but because PowerCLU will only
# do them one host at a time it is significantly quicker to unmount using the GUI, which unmounts from all hosts in parallel.
#
# This script therefore serves as little more than a quick way to bulk check a list of datastores.
#

# Load the stuff we need
.'C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'

# Connect to the vSphere server
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'
Connect-VIServer -Server $viServer

# Get the datastore names
$datastoreList = Get-Content -Path 'C:\Temp\DatastoresToRemoveNames.txt'

# Initialise the okToRemove List variable
$okToRemove += @()

# Check the datastores
ForEach ($datastoreName in $datastoreList) {
    $datastore = Get-Datastore -Name $datastoreName -Server $viServer

    # Are there VMs present?
    $vmsPresent = $datastore.ExtensionData.VM.Count -ne '0'

    # Are we in a cluster?
    $inCluster = $datastore.ExtensionData.Parent.Type -eq 'StoragePod'

    # The GUI checks to see if the datastore is managed by storage DRS so I'll check as well.
    # Although it's a bit pointless since SDRS can only be enabled on a cluster and we can't unmount if we're in a cluster...
    If ($inCluster) {
            $clusterName = (Get-View $datastore.ExtensionData.Parent).Name
            $sDRSEnabled = (Get-DatastoreCluster -Name $clusterName).SdrsAutomationLevel -ne 'Disabled'
        }
        Else {
            $sDRSEnabled = $false
        }

    # Is storeage IO control enabled?
    $storageIOCEnabled = $datastore.StorageIOControlEnabled

    # Are we being used for HA heartbeat?
    $clusterResource = Get-View -ViewType ClusterComputeResource

    If ($clusterResource) {
        $heartbeatDatastores = ($clusterResource.RetrieveDasAdvancedRuntimeInfo()).HeartbeatDatastoreInfo.Datastore
        $isHeartbeatDatastore = $heartbeatDatastores -contains $datastore.ExtensionData.MoRef
    }
    Else {
        $isHeartbeatDatastore = $false
    }

    # Check the results and write them to the screen
    $datastoreRemoveOK = $true

    # Write out the results
    Write-Host -Object ('Results for datastore: ' + $datastoreName)

    Write-Host -Object 'No virtual machine resides on the datastore: ' -NoNewline
    If (!$vmsPresent) {
        Write-Host -Object 'Passed' -ForegroundColor Green
    }
    Else {
        Write-Host -Object 'Failed' -ForegroundColor Red
        $datastoreRemoveOK = $false
    }

    Write-Host -Object 'The datastore is not part of a Datastore Cluster: ' -NoNewline
    If (!$inCluster) {
        Write-Host -Object 'Passed' -ForegroundColor Green
    }
    Else {
        Write-Host -Object 'Failed' -ForegroundColor Red
        $datastoreRemoveOK = $false
    }

    Write-Host -Object 'The datastore is not managed by storage DRS: ' -NoNewline
    If (!$sDRSEnabled) {
        Write-Host -Object 'Passed' -ForegroundColor Green
    }
    Else {
        Write-Host -Object 'Failed' -ForegroundColor Red
        $datastoreRemoveOK = $false
    }

    Write-Host -Object 'Storage I/O control is disabled for this datastore: ' -NoNewline
    If (!$storageIOCEnabled) {
        Write-Host -Object 'Passed' -ForegroundColor Green
    }
    Else {
        Write-Host -Object 'Failed' -ForegroundColor Red
        $datastoreRemoveOK = $false
    }

    Write-Host -Object 'The datastore is not used for vSphere HA heartbeat: ' -NoNewline
    If (!$isHeartbeatDatastore) {
        Write-Host -Object 'Passed' -ForegroundColor Green
    }
    Else {
        Write-Host -Object 'Failed' -ForegroundColor Red
        $datastoreRemoveOK = $false
    }

    # If the datastore can be removed, add it to the list
    If ($datastoreRemoveOK) {
        $okToRemove += $datastoreName
    }

    # Blank line to console
    Write-Host -Object ''
}

# Results summary
ForEach ($datastoreName in $datastoreList) {
    If ($datastoreName -in $okToRemove) {
        Write-Host -Object ('Datastore ' + $datastoreName + ' can be removed.') -ForegroundColor Green
    }
    Else {
        Write-Host -Object ('Datastore ' + $datastoreName + ' cannot be removed, please see check results above.') -ForegroundColor Red
    }
}

# Disconnect to the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

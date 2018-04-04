# Script to detach a list iSCSI LUNs from all the hosts in vSphere using their naa numbers
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

# Get list of datastores to detach from file
$datastoreNaas = Get-Content -Path 'C:\Temp\iSCSIToRemoveNaas.txt'

# Get all hosts attached to vSphere server
$vmHosts = Get-VMHost -Server $viServer | Sort-Object -Property Name

# Iterate through the hosts...
Foreach($vmHost in $vmHosts)
{
    # What's going on?
    Write-Host -Object ('Getting LUNs attached to ' + $vmHost + '... ')

    # Open a connection to the VMware Storage System
    $vmStorage = Get-View $vmHost.Extensiondata.ConfigManager.StorageSystem

    # Get details of LUNs attached to host
    $scsiLuns = $vmStorage.StorageDeviceInfo.ScsiLun

    # Iterate through the datastores to be removed...
    Foreach($datastoreNaa in $datastoreNaas) {

        # What's going on?
        Write-Host -Object ('Detaching LUN ' + $datastoreNaa + ' from ' + $vmHost + '... ') -NoNewline

        If ($datastoreNaa -in $scsiLuns.CanonicalName){
            # Get the UUID of the iSCSI LUN
            $lunUuid = ($scsiLuns | Where-Object {$_.CanonicalName -eq $datastoreNaa}).Uuid

            # Detach the LUN from the host using the UUID
            $vmStorage.DetachScsiLun($lunUuid)

            # Update on progress
            Write-Host -Object 'Detached.' -ForegroundColor Green
        }

        Else {
            # Update on progress
            Write-Host -Object 'Not attached.' -ForegroundColor Red
        }
    }
    # Just a blank line to seperate the next host
    Write-Host -Object ''
}

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

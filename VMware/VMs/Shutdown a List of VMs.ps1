# Bulk shutdown VMs using a list from an input file
#
# Written for PowerCLI 10
#

# Get Credentials
$viCredential = Get-Credential -Message 'Enter credentials for VMware connection'

# Get vSphere server name
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'

# Import the PowerCLI Module and Connect
Import-Module -Name VMware.PowerCLI -Force
Connect-VIServer -Server $viServer -Credential $viCredential

# Path to file containing list of VM's to shutdown
$vmsToShutdownFile = 'C:\Temp\VMsToShutdown.txt'

# Get list of VMs to be shutdown from file
$vmsToShutdown = Get-Content -Path $vmsToShutdownFile

# Check to see if each VM in the list is powered on, if it is then shut it down.
foreach ($VM in $vmsToShutdown) {
    $vmDetails = Get-VM -Name $VM -Server $viServer
    if ($vmDetails.PowerState -eq 'PoweredOn') {
        $vmDetails | Shutdown-VMGuest -Confirm:$false
    }
    else {
        Write-Host -Object ('VM ' + $VM + ' is not powered on.') -ForegroundColor Red
    }
}

# Check PowerState of VMs.
Get-VM -Name $vmsToShutdown | Format-Table Name,PowerState

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

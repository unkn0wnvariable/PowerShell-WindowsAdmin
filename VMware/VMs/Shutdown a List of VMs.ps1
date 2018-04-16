# Bulk shutdown VMs using a list from an input file
#
# Created for PowerCLI 10
#

# Import the PowerCLI Module
Import-Module -Name VMware.PowerCLI -Force

#Get Credentials
$viCredential = Get-Credential -Message 'Enter credentials for VMware connection'

# Connect to the vSphere server
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'
Connect-VIServer -Server $viServer -Credential $viCredential

# Path to file containing list of VM's to shutdown
$vmsToShutdownFile = 'C:\Temp\VMsToShutdown.txt'

# Get list of VMs to be shutdown from file
$vmsToShutdown = Get-Content -Path $vmsToShutdownFile

# Check to see if each VM in the list is powered on, if it is then shut it down.
ForEach ($VM in $vmsToShutdown) {
    $vmDetails = Get-VM -Name $VM -Server $viServer
    If ($vmDetails.PowerState -eq 'PoweredOn') {
        $vmDetails | Shutdown-VMGuest -Confirm:$false
    }
    Else {
        Write-Host -Object ('VM ' + $VM + ' is not powered on.') -ForegroundColor Red
    }
}

# Check PowerState of VMs.
Get-VM -Name $vmsToShutdown | Format-Table Name,PowerState

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

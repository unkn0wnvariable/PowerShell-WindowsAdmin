# Bulk delete VMs using a list from an input file
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

# Path to file containing list of VM's to delete
$vmsToDeleteFile = 'C:\Temp\VMsToDelete.txt'

# Get list of VMs to be deleted from file
$vmsToDelete = Get-Content -Path $vmsToDeleteFile

# Check to see if each VM in the list is powered off, if it is then delete it.
ForEach ($VM in $vmsToDelete) {
    $vmDetails = Get-VM -Name $VM
    If ($vmDetails.PowerState -eq 'PoweredOff') {
        $vmDetails | Remove-VM -DeletePermanently -RunAsync -Confirm:$false
    }
    Else {
        Write-Host -Object ('VM ' + $VM + ' is not powered off.') -ForegroundColor Red
    }
}

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

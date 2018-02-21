# Bulk delete VMs using a list from an input file


# Load stuff

# PowerCLI includes a script to check the necessary modules are installed and then load them all. There's no real point
# in replicating all that in every script I make, so lets just used it as is.
#
# This is the default location for the PowerCLI script, it should be correct unless a custom install location was used.
$powerCLIPath = 'C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'

# Check the PowerCLI script exists and load it if it does, if not notify and terminate.
If (Test-Path -Path $powerCLIPath) {
    .$powerCLIPath
}
Else {
    Write-Host -Object 'The PowerCLI Environment Initialization script was not found.'
    Break
}


# Get stuff

# Path to file containing list of VM's to delete
$vmsToDeleteFile = 'C:\Temp\VMsToDelete.txt'

# Ask for the name of the VI server
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'


# Do stuff

# Get list of VMs to be deleted from file
$vmsToDelete = Get-Content -Path $vmsToDeleteFile

# Connect to the VI server
Connect-VIServer -Server $viServer

# Check to see if each VM in the list is powered off, if it is then delete it.
ForEach ($VM in $vmsToDelete) {
    $vmDetails = Get-VM -Name $VM
    If ($vmDetails.PowerState -eq 'PoweredOff') {
        Remove-VM -VM $VM -Server $viServer -DeletePermanently -RunAsync -Confirm:$false
    }
    Else {
        Write-Host -Object ('VM ' + $VM + ' is not powered off.')
    }
}

# Disconnect from the VI server
Disconnect-VIServer -Server $viServer -Confirm:$false

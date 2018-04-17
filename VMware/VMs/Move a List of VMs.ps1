# Bulk Move VMs to Different Datastores Based on CSV Input
#
# Input CSV file should be in the format of 2 columns headed Name and TargetDatastore
# with each row containing the VM name and the datastore to which it is to be moved.
#
# Updated for PowerCLI 10
#

# Get Credentials
$viCredential = Get-Credential -Message 'Enter credentials for VMware connection'

# Get vSphere server name
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'

# Import the PowerCLI Module and Connect
Import-Module -Name VMware.PowerCLI -Force
Connect-VIServer -Server $viServer -Credential $viCredential

# Path to file containing list of VM's to move
$vmsToMoveFile = 'C:\Temp\VMsToMoveStorage.csv'

# Get list of VMs to be deleted from file
$vmsToMove = Import-Csv -Path $vmsToMoveFile

# Move each VM to its target datastore
ForEach ($VM in $vmsToMove) {
    Move-VM -VM $VM.Name -Server $viServer -Datastore $VM.TargetDatastore
}

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

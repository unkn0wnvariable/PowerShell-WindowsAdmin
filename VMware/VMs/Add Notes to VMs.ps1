# Add Notes to VMs
# 
# Written for PowerCLI 10
#

<#
Please note:

This script uses a CSV file as input and expects that file to have 5 columns, which are
expected to be vmname, service, product, owner and description.

There is no reason for this other than it just happens to be the information that we store
in the VM notes - feel free to change it to suit your own needs.
#>

# Get Credentials
$viCredential = Get-Credential -Message 'Enter credentials for VMware connection'

# Get vSphere server name
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'

# Import the PowerCLI Module and Connect
Import-Module -Name VMware.PowerCLI -Force
Connect-VIServer -Server $viServer -Credential $viCredential

# The CSV file containing all the info.
$inputFile = 'C:\Temp\vm-notes.csv'

# Each line of notes to add.
$allVMs = Import-Csv -Path $inputFile

# For each line of the CSV file, compile the notes and add them to the VM.
foreach ($vm in $allVMs) {
    $notes = @(
        ('Service: ' + $vm.service),
        ('Product: ' + $vm.product),
        ('Owner: ' + $vm.owner),
        ('Description: ' + $vm.description)
    ) -join "`n"
    Get-VM -Server $viServer -Name $vm.vmname | Set-VM -Notes $notes -Confirm:$false
}

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

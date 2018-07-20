# Script to get a list of all powered on VM's from the specified vCenter server
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

# Where to save the list to
$outputfile = 'C:\Temp\VMware Guests.csv'

# Get all VMs
$vms = Get-VM -Server $viServer

# Initialise the output object
$outputTable = @()

# Build the output object from the VM list
foreach ($vm in $vms) {
    $outputRow = [pscustomobject]@{
        'Name' = $vm.Name;
        'PowerState' = $vm.PowerState;
        'GuestOS' = $vm.Guest.OSFullName;
        'ResourcePool' = $vm.ResourcePool;
        'Notes' = ($vm.Notes -replace '\n','; ')
    }
    $outputTable += $outputRow
}

# Output to a CSV file
$outputTable | Export-Csv -Path $outputfile -NoTypeInformation

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

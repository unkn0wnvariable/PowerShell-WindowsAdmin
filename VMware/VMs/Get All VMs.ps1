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
    $outputRow = New-Object System.Object
    $outputRow | Add-Member -MemberType NoteProperty -Name 'Name' -Value $vm.Name
    $outputRow | Add-Member -MemberType NoteProperty -Name 'PowerState' -Value $vm.PowerState
    $outputRow | Add-Member -MemberType NoteProperty -Name 'GuestOS' -Value $vm.Guest.OSFullName
    $outputRow | Add-Member -MemberType NoteProperty -Name 'ResourcePool' -Value $vm.ResourcePool
    $outputRow | Add-Member -MemberType NoteProperty -Name 'Notes' -Value ($vm.Notes -replace '\n','; ')
    $outputTable += $outputRow
}

# Output to a CSV file
$outputTable | Export-Csv -Path $outputfile -NoTypeInformation

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

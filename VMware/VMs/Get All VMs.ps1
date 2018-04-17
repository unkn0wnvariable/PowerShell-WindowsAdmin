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

# Get all Powered On VMs
$vms = Get-VM -Server $viServer | Where-Object {$_.PowerState -eq 'PoweredOn'} | Select-Object VMHost,Name,Guest,ResourcePool,Notes

# Initialise the output object
$vmsTable = @()

# Build the output object from the VM list
foreach ($vm in $vms) {
    $tableRow = New-Object System.Object
    $tableRow | Add-Member -MemberType NoteProperty -Name 'VMHost' -Value $vm.VMHost.Name
    $tableRow | Add-Member -MemberType NoteProperty -Name 'Name' -Value $vm.Name
    $tableRow | Add-Member -MemberType NoteProperty -Name 'GuestOS' -Value $vm.Guest.OSFullName
    $tableRow | Add-Member -MemberType NoteProperty -Name 'ResourcePool' -Value $vm.ResourcePool
    $tableRow | Add-Member -MemberType NoteProperty -Name 'Notes' -Value ($vm.Notes -replace "`n"," ")
    $vmsTable += $tableRow
}

# Output to a CSV file
$vmsTable | Export-Csv -Path $outputfile -NoTypeInformation

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

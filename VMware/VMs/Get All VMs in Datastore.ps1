# Script to get a list of all VMs in one or more datastores
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
$outputfile = 'C:\Temp\VMsByDatastore.csv'

# Which datastores to get VMs for?
# For example, using a wildcard to get all datastores with similar names
$datastores = Get-Datastore | Where-Object {$_.Name -like '*Tier*'}

# Initialise the output object
$outputTable = @()

# Build the output object from the VM list
foreach ($datastore in $datastores) {
    $vms = Get-VM -Datastore $datastore
    foreach ($vm in $vms) {
        $outputRow = New-Object System.Object
        $outputRow | Add-Member -MemberType NoteProperty -Name 'Name' -Value $vm.Name
        $outputRow | Add-Member -MemberType NoteProperty -Name 'PowerState' -Value $vm.PowerState
        $outputRow | Add-Member -MemberType NoteProperty -Name 'Datastore' -Value $datastore
        $outputRow | Add-Member -MemberType NoteProperty -Name 'Notes' -Value ($vm.Notes -replace "`n"," ")
        $outputTable += $outputRow
    }
}

# Output to a CSV file
$outputTable | Export-Csv -Path $outputfile -NoTypeInformation

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

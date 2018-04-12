# Get VM guest info to a CSV file
#
# Updated for PowerCLI 10
#

# Output file path
$outputFile = 'C:\Temp\VMGuestDetails.csv'

# Get Credentials
$viCredential = Get-Credential -Message 'Enter credentials for VMware connection'

# Get vCenter server name
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'

# Import the PowerCLI Module and connect to the vSphere server
Import-Module -Name VMware.PowerCLI -Force -DisableNameChecking
Connect-VIServer -Server $viServer -Credential $viCredential

# Get VM guest details of all powered on VMs
$allVmGuests = Get-VM -Server $viServer | Get-VMGuest

# Initialise the output hash table
$outputTable = @()

# Build the output object from the VM list
ForEach ($vmGuest in $allVmGuests) {
    $outputRow = New-Object System.Object
    $outputRow | Add-Member -MemberType NoteProperty -Name 'VMName' -Value $vmGuest.VmName
    $outputRow | Add-Member -MemberType NoteProperty -Name 'HostName' -Value $vmGuest.HostName
    $outputRow | Add-Member -MemberType NoteProperty -Name 'IPAddresses' -Value ($vmGuest.IPAddress -join ';')
    $outputRow | Add-Member -MemberType NoteProperty -Name 'OSFullName' -Value ($vmGuest.OSFullName -replace "`n"," ")
    $outputRow | Add-Member -MemberType NoteProperty -Name 'ToolsState' -Value $vmGuest.State
    $outputRow | Add-Member -MemberType NoteProperty -Name 'ToolsVersion' -Value $vmGuest.ToolsVersion
    $outputTable += $outputRow
}

# Output data to CSV file
$outputTable | Export-Csv -Path $outputFile -NoTypeInformation

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

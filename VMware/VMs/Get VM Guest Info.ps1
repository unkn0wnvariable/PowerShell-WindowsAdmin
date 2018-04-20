# Get VM guest info to a CSV file
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

# Output file path
$outputFile = 'C:\Temp\VMGuestDetails.csv'

# Get VM guest details of all powered on VMs
$allVmGuests = Get-VM -Server $viServer | Get-VMGuest

# Initialise the output hash table
$outputTable = @()

# Build the output object from the VM list
foreach ($vmGuest in $allVmGuests) {
    $outputTable += [pscustomobject]@{
        'VMName' = $vmGuest.VmName
        'HostName' = $vmGuest.HostName
        'IPAddresses' = ($vmGuest.IPAddress -join '; ')
        'OSFullName' = ($vmGuest.OSFullName -replace '\n','; ')
        'ToolsState' = $vmGuest.State
        'ToolsVersion' = $vmGuest.ToolsVersion
    }
}

# Output data to CSV file
$outputTable | Export-Csv -Path $outputFile -NoTypeInformation

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

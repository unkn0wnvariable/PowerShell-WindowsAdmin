# Get the size and current datastore location for a list of VMs
#
# Written for PowerCLI 10
#

# Get Credentials
$viCredential = Get-Credential -Message 'Enter credentials for VMware connection'

# Get vSphere server name
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'

# Import the PowerCLI Module and Connect
Import-Module -Name VMware.PowerCLI -Force
Connect-VIServer -Server $viServer -Credential $viCredential

# Path to file containing list of VM's to shutdown
$vmListFile = 'C:\Temp\VMList.txt'

# Path to create output file
$outputFile = 'C:\Temp\VMList.csv'

# Get list of VMs from file and remove any duplicates
$vmList = Get-Content -Path $vmListFile | Sort-Object -Unique

# Create blank hashtable for results
$outputTable = @()

# Run through the VM's getting the information we need
foreach ($VM in $vmList) {
    Write-Host ('Getting Details for ' + $VM)
    try {
        $vmDetails = Get-VM -Name $VM -Server $viServer -ErrorAction Stop
        $datastoreName = (Get-View $vmDetails.DatastoreIdList).Name
        $vmProvisionedSpace = [math]::Round($vmDetails.ProvisionedSpaceGB,2)
        $outputRow = [pscustomobject]@{
            'VM Name'=$VM;
            'Size (GB)'=$vmProvisionedSpace;
            'Current Datastore'=$datastoreName
        }
    }
    catch {
        $outputRow = [pscustomobject]@{
            'VM Name'=$VM;
            'Size (GB)'='0';
            'Current Datastore'='Deleted'
        }
    }
    $outputTable += $outputRow
}

# Output the collected info to a file
$outputTable | Export-Csv -Path $outputFile -NoTypeInformation

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

# Output a CSV file containing some details about powered off VMs
#
# Created for PowerCLI 10
#

# Import the PowerCLI Module
Import-Module -Name VMware.PowerCLI -Force

#Get Credentials
$viCredential = Get-Credential -Message 'Enter credentials for VMware connection'

# Connect to the vSphere server
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'
Connect-VIServer -Server $viServer -Credential $viCredential

# Path to create output file
$outputFile = 'C:\Temp\PoweredOffVMs.csv'

# Get list of all powered off VMs
$vmList = Get-VM -Server $viServer | Where-Object {$_.PowerState -eq 'PoweredOff'}

# Create blank hashtable for results
$outputTable = @()

# Run through the VM's getting the information we need
ForEach ($vm in $vmList) {
    $datastoreName = (Get-View $vm.DatastoreIdList).Name
    $vmProvisionedSpace = [math]::Round($vm.ProvisionedSpaceGB,2)
    $vmFolder = $vm.Folder
    $vmNotes = $vm.Notes
    $vmResourcePool = $vm.ResourcePool
    $outputLine = [pscustomobject]@{'VM Name'=$vm.Name;'Size (GB)'=$vmProvisionedSpace;'Folder'=$vmFolder;'Datastore'=$datastoreName;'Resource Pool'=$vmResourcePool;'Notes'=$vmNotes}
    $outputTable += $outputLine
}

# Output the collected info to a file
$outputTable | Export-Csv -Path $outputFile -NoTypeInformation

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

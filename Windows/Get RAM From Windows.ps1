# Get Memory Information from Remote Computer
#

# What computer are we accessing?
$computerName = Read-Host -Prompt 'Enter computer to get information from'

# Use WMI to get the information
$physicalMemoryArray = @(Get-WmiObject -Class 'win32_PhysicalMemoryArray' -namespace 'root\CIMV2' -ComputerName $computerName)
$physicalMemory = @(Get-WmiObject -Class 'win32_PhysicalMemory' -namespace 'root\CIMV2' -ComputerName $computerName)

# How many memory arrays are there?
Write-Output -InputObject ('Computer has ' + $physicalMemoryArray.Count + ' memory array(s).')

# How many slots does each array have?
foreach ($memoryArray in $physicalMemoryArray){
     Write-Output -InputObject ('Total DIMM Slots in ' + $memoryArray.Tag + ': ' + $memoryArray.MemoryDevices)
}

# What's installed in the arrays?
foreach ($memoryObject in $physicalMemory) {
     Write-Output -InputObject ('DIMM installed in ' + $memoryObject.DeviceLocator + ': ' + ($memoryObject.Capacity / 1GB) + 'GB')
}

# Get Memory Information from Remote Computer
#

# What computer are we accessing?
$ComputerName = Read-Host -Prompt 'Enter computer to get information from'

# Use WMI to get the information
$PhysicalMemoryArray = @(Get-WmiObject -Class 'win32_PhysicalMemoryArray' -namespace 'root\CIMV2' -ComputerName $ComputerName)
$PhysicalMemory = @(Get-WmiObject -Class 'win32_PhysicalMemory' -namespace 'root\CIMV2' -ComputerName $ComputerName)

# How many memory arrays are there?
Write-Output -InputObject ('Computer has ' + $PhysicalMemoryArray.Count + ' memory array(s).')

# How many slots does each array have?
foreach ($MemoryArray in $PhysicalMemoryArray){
     Write-Output -InputObject ('Total DIMM Slots in ' + $MemoryArray.Tag + ': ' + $MemoryArray.MemoryDevices)
}

# What's installed in the arrays?
foreach ($MemoryObject in $PhysicalMemory) {
     Write-Output -InputObject ('DIMM installed in ' + $MemoryObject.DeviceLocator + ': ' + ($MemoryObject.Capacity / 1GB) + 'GB')
}

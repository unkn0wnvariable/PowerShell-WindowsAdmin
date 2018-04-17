# Script to get a list of NIC driver and firmware versions and output them to a CSV file
#
# I'm using a rubbish way of generating a CSV file here, please don't copy it
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

# Set location of the output file
$outputfile = 'C:\Temp\VMware Firmware.csv'

# Set and write the column headers to the file
$fileheader = '"vmhost","Driver","FirmwareVersion"'
Write-Output $fileheader | Out-File $outputfile -Encoding utf8 -Force

# Get all VMhosts from the VIServer
$vmhosts = Get-VMHost -Server $viServer

# Run through the VMhosts getting their NIC driver/firmware details and outputting them to file
ForEach ($vmhost in $vmhosts) {
    $esxcli = $null
    $esxcli = Get-ESXCli -VMHost $vmhost.Name -Server $viServer
    $nicInfo = $esxcli.network.nic.get('vmnic0').DriverInfo
    $output = '"' + $vmhost.Name + '","' + $nicInfo.Driver + '","' + $nicInfo.FirmwareVersion + '"'
    Write-Output $output | Out-File $outputfile -Encoding utf8 -Force -Append
}

# Disconnect from the vSphere server
Disconnect-VIServer -Confirm:$false -Server $viServer

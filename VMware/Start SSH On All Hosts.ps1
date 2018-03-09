# Script to Enable SSH on all hosts
#
# Updated for PowerCLI 10
#

# Import the PowerCLI Module
Import-Module -Name VMware.PowerCLI -Force

#Get Credentials
$viCredential = Get-Credential -Message 'Enter credentials for VMware connection'

# Connect to the vSphere server
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'
Connect-VIServer -Server $viServer -Credential $viCredential

# Start SSH on hosts
Get-VMHost -Server $viServer | ForEach-Object {Start-VMHostService -HostService ($_ | Get-VMHostService | Where-Object {$_.Key -eq “TSM-SSH”})}

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

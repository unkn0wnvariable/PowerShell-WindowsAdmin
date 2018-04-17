# Script to Enable SSH on all hosts
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

# Stop SSH on hosts
Get-VMHost -Server $viServer | ForEach-Object {Stop-VMHostService -HostService ($_ | Get-VMHostService | Where-Object {$_.Key -eq “TSM-SSH”}) -Confirm:$false}

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

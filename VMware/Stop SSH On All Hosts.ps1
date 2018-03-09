# Script to Enable SSH on all hosts
#
# Updated for PowerCLI 10
#
# If you're using self signed certificates you will need to revert the invalid certificate
# behaviour to warn instead of stop, as was the case in PowerCLI 6.5
#
# This is done using the following command:
#
# Set-PowerCLIConfiguration -InvalidCertificateAction Warn -Confirm:$false
#

# Import the PowerCLI Module
Import-Module -Name VMware.PowerCLI

#Get Admin Credentials
$adminCreds = Get-Credential -Message 'Enter account details with admin rights to VMware'

# Connect to the vSphere server
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'
Connect-VIServer -Server $viServer -Credential $adminCreds

# Stop SSH on hosts
Get-VMHost -Server $viServer | ForEach {Stop-VMHostService -HostService ($_ | Get-VMHostService | Where {$_.Key -eq “TSM-SSH”}) -Confirm:$false}

# Disconnect vCenter
Disconnect-VIServer -Server $viServer -Confirm:$false

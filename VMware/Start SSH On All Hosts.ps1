# Script to Enable SSH on all hosts


# Initialise PowerCLI Environment
.'C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'

#Get Admin Credentials
$adminCreds = Get-Credential -Message 'Enter account details with admin rights to VMware'

# Connect to the vSphere server
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'
Connect-VIServer -Server $viServer -Credential $adminCreds

# Start SSH on hosts
Get-VMHost -Server $viServer | ForEach {Start-VMHostService -HostService ($_ | Get-VMHostService | Where {$_.Key -eq “TSM-SSH”})}

# Disconnect vCenter
Disconnect-VIServer -Server $viServer -Confirm:$false

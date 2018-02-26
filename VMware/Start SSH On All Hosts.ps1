# Script to Enable SSH on all hosts


# Initialise PowerCLI Environment
.'C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'

# Get- VIServer
$viServer = Read-Host -Prompt 'Enter the FQDN of your VI server'

# Connect vCenter
Connect-VIServer -Server $viServer

# Start SSH on hosts
Get-VMHost -Server $viServer | ForEach {Start-VMHostService -HostService ($_ | Get-VMHostService | Where {$_.Key -eq “TSM-SSH”})}

# Disconnect vCenter
Disconnect-VIServer -Server $viServer -Confirm:$false

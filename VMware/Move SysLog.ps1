# Get list of dump files from ESXi hosts, and remove them if required


# Initialise PowerCLI Environment
.'C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'

#Get Admin Credentials
$adminCreds = Get-Credential -Message 'Enter account details with admin rights to VMware'

# Connect to the vSphere server
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'
Connect-VIServer -Server $viServer -Credential $adminCreds

# New Log Datastore
$logDatastore = 'MK-Local-HostLogs-01'

# What should the log path be?
$logDatastoreUuid = (Get-Datastore -Name $logDatastore -Server $viServer).ExtensionData.Info.Vmfs.Uuid
Write-Host -Object ('New log path should be: /vmfs/volumes/' + $logDatastoreUuid + '/logdir')

# Get all ESX hosts
$esxHosts = Get-VMHost -Server $viServer

# Iterate through the hosts checking log settings
ForEach ($esxHost in $esxHosts) { 
    $esxCli = Get-EsxCli -VMHost $esxHost -Server $viServer -V2
    $logSettings = $esxCli.system.syslog.config.get.Invoke()
    Write-Host -Object ('ESXi Host: ' + $esxHost.Name)
    Write-Host -Object ('Log Path: ' + $logSettings.LocalLogOutput)
    Write-Host -Object ('Create subdirectory: ' + $logSettings.LogToUniqueSubdirectory)
}

# Iterate through the hosts reloading syslog
ForEach ($esxHost in $esxHosts) { 
    $esxCli = Get-EsxCli -VMHost $esxHost -Server $viServer -V2
    $esxCli.system.syslog.reload.Invoke()
}

# Disconnect vCenter
Disconnect-VIServer -Server $viServer -Confirm:$false

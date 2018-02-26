# Get list of dump files from ESXi hosts, and remove them if required


# Initialise PowerCLI Environment
.'C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'

# Get- VIServer
$viServer = Read-Host -Prompt 'Enter the FQDN of your VI server'

# Connect vCenter
Connect-VIServer -Server $viServer

# Get all dumpfile details and display them
$dumpfiles = @()

# Iterate through the hosts getting the active and configured dumpfiles from them
ForEach ($esxHost in (Get-VMHost -Server $viServer)) { 
    $esxCli = Get-EsxCli -VMHost $esxHost -Server $viServer -V2
    $activeDumpfile = $esxCli.system.coredump.file.get.Invoke().Active
    $configuredDumpfile = $esxCli.system.coredump.file.get.Invoke().Configured
    $dumpfileDetails = @($esxHost.Name,$activeDumpfile,$configuredDumpfile)
    $objProperties = @{'VMHost'=$esxHost.Name;'Active'=$activeDumpfile;'Configured'=$configuredDumpfile}
    $dumpfiles += New-Object –TypeName PSObject –Prop $objProperties
}

# Lets see a list of those dumpfiles
$dumpfiles | Select VMHost,Active,Configured | FT -AutoSize


# Do you want to remove the dump files?
$remove = ''
While ($remove -notmatch '[Yy|Nn]') {
    $remove = Read-Host -Prompt 'Do you want to remove the dump files? (Y/N)'
}

# If required then remove the dumpfiles
# Iterate through the entries in the dumpfiles variable
# If there is an active or configured dumpfile then unconfigure it
If ($remove -match '[Yy]') {
    ForEach ($dumpfile in $dumpfiles) {
        If ($dumpfile.Active -ne '' -or $dumpfile.Configured -ne '') {
            Write-Host ('Removing dumpfile for ' + $dumpfile.VMHost + '... ') -ForegroundColor Red -NoNewline
            $esxCli = Get-EsxCli -VMHost $dumpfile.VMHost -Server $viServer -V2
            $esxCli.system.coredump.file.set.Invoke(@{unconfigure = $true}) | Out-Null
            Write-Host 'Complete.' -ForegroundColor Red
        }
    }
    Write-Host 'All dump files removed.' -ForegroundColor Red
}
Else {
    Write-Host 'No action taken.' -ForegroundColor Green
}

# Disconnect vCenter
Disconnect-VIServer -Server $viServer -Confirm:$false

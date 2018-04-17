# Get list of dump files from ESXi hosts, and remove them if required
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

# Initialize an object to collect the details into
$dumpfiles = @()

# Iterate through the hosts getting the active and configured dumpfiles from them
ForEach ($esxHost in (Get-VMHost -Server $viServer)) { 
    $esxCli = Get-EsxCli -VMHost $esxHost -Server $viServer -V2
    $activeDumpfile = $esxCli.system.coredump.file.get.Invoke().Active
    $configuredDumpfile = $esxCli.system.coredump.file.get.Invoke().Configured
    $objProperties = @{'VMHost'=$esxHost.Name;'Active'=$activeDumpfile;'Configured'=$configuredDumpfile}
    $dumpfiles += New-Object –TypeName PSObject –Prop $objProperties
}

# Lets see a list of those dumpfiles
$dumpfiles | Select-Object VMHost,Active,Configured | Format-Table -AutoSize

# Do you want to remove the dump files?
$remove = ''
While ($remove -notmatch '^[YyNn]$') {
    $remove = Read-Host -Prompt 'Do you want to remove the dump files? (Y/N)'
}

# If required then remove the dumpfiles
# Iterate through the entries in the dumpfiles variable
# If there is an active or configured dumpfile then unconfigure it
If ($remove -match '[Yy]') {
    ForEach ($dumpfile in $dumpfiles) {
        If ($dumpfile.Active -ne '' -or $dumpfile.Configured -ne '') {
            Write-Host ('Removing dumpfile for ' + $dumpfile.VMHost + '... ') -NoNewline
            $esxCli = Get-EsxCli -VMHost $dumpfile.VMHost -Server $viServer -V2
            $esxCli.system.coredump.file.set.Invoke(@{unconfigure = $true}) | Out-Null
            Write-Host 'Complete.' -ForegroundColor Green
        }
    }
    Write-Host 'All dump files removed.' -ForegroundColor Green
}
Else {
    Write-Host 'No action taken.' -ForegroundColor Green
}

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

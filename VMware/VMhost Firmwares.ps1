
.'C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'

$outputfile = 'C:\Temp\VMware Firmware.csv'
$fileheader = '"vmhost","Driver","FirmwareVersion"'

$viServer = Read-Host -Prompt 'Enter VMware viServer FQDN:'

Write-Output $fileheader | Out-File $outputfile -Encoding utf8 -Force

Connect-VIServer -Server $viServer

$vmhosts = Get-VMHost -Server $viServer

ForEach ($vmhost in $vmhosts) {
    $esxcli = $null
    $esxcli = Get-ESXCli -VMHost $vmhost.Name -Server $viServer
    $nicInfo = $esxcli.network.nic.get('vmnic0').DriverInfo
    $output = '"' + $vmhost.Name + '","' + $nicInfo.Driver + '","' + $nicInfo.FirmwareVersion + '"'
    Write-Output $output | Out-File $outputfile -Encoding utf8 -Force -Append
}

Disconnect-VIServer -Confirm:$false -Server $viServer

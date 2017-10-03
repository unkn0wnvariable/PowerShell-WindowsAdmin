Add-PSSnapin VMware.VimAutomation.Core -ea "SilentlyContinue"
Add-PSSnapin VMware.VimAutomation.Vds -ea "SilentlyContinue"

.'C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'

$outputfile = 'C:\Temp\VMware Guests.csv'

$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'

$allVMs = @()

Connect-VIServer -Server $viServer

$vms = Get-VM -Server $viServer.Name | Where {$_.PowerState -eq 'PoweredOn'} | Select VMHost,Name,Guest,ResourcePool,Notes

Disconnect-VIServer -Confirm:$false -Server $viServer

$vmsTable = @()

ForEach ($vm in $vms) {
    $tableRow = New-Object System.Object
    $tableRow | Add-Member -MemberType NoteProperty -Name 'VMHost' -Value $vm.VMHost.Name
    $tableRow | Add-Member -MemberType NoteProperty -Name 'Name' -Value $vm.Name
    $tableRow | Add-Member -MemberType NoteProperty -Name 'GuestOS' -Value $vm.Guest.OSFullName
    $tableRow | Add-Member -MemberType NoteProperty -Name 'ResourcePool' -Value $vm.ResourcePool
    $tableRow | Add-Member -MemberType NoteProperty -Name 'Notes' -Value ($vm.Notes -replace "`n"," ")
    $vmsTable += $tableRow
}

$vmsTable | Export-Csv -Path $outputfile -NoTypeInformation

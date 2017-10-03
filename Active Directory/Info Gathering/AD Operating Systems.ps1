# List operating systems in AD and how many machines are running each one.

$adComputers = Get-ADComputer -Filter * -Properties OperatingSystem
$operatingSystems = $adComputers.OperatingSystem | Sort-Object -Unique

ForEach ($operatingSystem in $operatingSystems) {
    $computers = ($adComputers | Where-Object {$_.OperatingSystem -eq $operatingSystem}).Name
    Write-Host ([string]$computers.Count + ' running ' + $operatingSystem + '.')
}

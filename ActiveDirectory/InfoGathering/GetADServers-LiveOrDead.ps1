# Script to get all servers from Active Directory and check if they're alive or not
#

# Import the AD PowerShell module
Import-Module ActiveDirectory

# Get all AD copmuters with an operating system that contains the word server
$servers = Get-ADComputer -Filter * -Properties OperatingSystem | Where-Object {$_.OperatingSystem -like '*Server*' -and $_.Enabled -eq $true}

# Create empty arrays for output
$liveServers = @()
$deadServers = @()

# Run through the servers testing if they respond or not
foreach ($server in $servers) {
    Write-Progress -Activity 'Testing connection to..' -status $server.Name -percentComplete ($servers.IndexOf($server) / $servers.Count * 100)
    $alive = Test-Connection -ComputerName $server.DNSHostName -Quiet

    # If the server repsonds add it to $liveServers, if not add it to $deadServers
    if ($alive) {
        $liveServers += $server
    }
    else {
        $deadServers += $server
    }
}

# Output the results to two CSV files
$liveServers | Export-Csv 'C:\Temp\LiveADServers.csv' -NoTypeInformation
$deadServers | Export-Csv 'C:\Temp\DeadADServers.csv' -NoTypeInformation

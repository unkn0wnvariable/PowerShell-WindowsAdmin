# Script to get network details for a list of servers via WMI
#

# Get list of servers from a file
$computerNames = Get-Content -Path 'C:\Temp\ComputerNames.txt'

# Create empty table to collect results
$networkDetails = @()

# Work through the computers from the file
foreach ($computerName in $computerNames) {
    # Which one are we checking?
    Write-Output -InputObject ('Checking server: ' + $computerName)

    # Try the WMI approach
    try {
        # Get the network adapters from the server via WMI
        $networkAdapters = Get-WmiObject -Class 'Win32_NetworkAdapterConfiguration' -Filter 'IPEnabled = true' -ComputerName $computerName -ErrorAction:Stop

        # Iterate through the network adapters
        foreach ($networkAdapter in $networkAdapters) {

            # If both WINS server settings are present, join them together with a ;. Else just concatenate the vaules.
            if ($networkAdapter.WINSPrimaryServer -and $networkAdapters.WINSSecondaryServer) {
                $winsServers = $networkAdapter.WINSPrimaryServer + '; ' + $networkAdapters.WINSSecondaryServer
            }
            else {
                $winsServers = $networkAdapter.WINSPrimaryServer + $networkAdapters.WINSSecondaryServer
            }

            # Create an object with the results in and add it to networkDetails
            $networkDetails += [PSCustomObject]@{
                'ServerName' = $computerName;
                'Adapter' = $networkAdapter.Description;
                'IPAddresses' = $networkAdapter.IPAddress -join '; ';
                'DNSServers' = $networkAdapter.DNSServerSearchOrder -join '; ';
                'WINSServers' = $winsServers
            }
        }
    }
    catch {
        # If WMI fails then just add an entry with the computer name to say it failed
        $networkDetails += [PSCustomObject]@{
            'ServerName' = $computerName;
            'Adapter' = 'Connection Failed';
            'IPAddresses' = '';
            'DNSServers' = '';
            'WINSServers' = ''
        }
    }
}

# Output the results to an Excel file
$networkDetails | Export-Excel -Path 'C:\Temp\NetworkDetails.xlsx'

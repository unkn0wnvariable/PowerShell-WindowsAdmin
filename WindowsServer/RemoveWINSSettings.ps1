# Script to remove WINS settings from a list of servers via WMI
#

# Get list of servers from a file
$computerNames = Get-Content -Path 'C:\Temp\ComputerNames.txt'

# Get administrative credentials
$credentials = Get-Credential -Message 'Enter your admin credentials'

# Work through the computers from the file
foreach ($computerName in $computerNames) {
    # Which one are we checking?
    Write-Output -InputObject ('Connecting to: ' + $computerName)

    # Try the WMI approach
    try {
        # Get the network adapters from the server via WMI
        $networkAdapters = Get-WmiObject -Class 'Win32_NetworkAdapterConfiguration' -Filter 'IPEnabled = True' -ComputerName $computerName -Credential $credentials -ErrorAction:Stop

        # Iterate through the network adapters
        foreach ($networkAdapter in $networkAdapters) {

            # If WINS server settings are present, remove them.
            if ($networkAdapter.WINSPrimaryServer -notlike '' -or $networkAdapter.WINSSecondaryServer -notlike '') {
                $response = $networkAdapter.SetWINSServer('','')
                if ($response.ReturnValue -eq 0) {
                    Write-Output -InputObject ('Settings sucessfully removed from ' + $networkAdapter.Description + ' on ' + $computerName)
                }
                else {
                    Write-Output -InputObject ('Failed to remove settings from ' + $networkAdapter.Description + ' on ' + $computerName + ' with return value ' + $response.ReturnValue + '.')
                }
            }
        }
    }
    catch {
        # If WMI fails output a message
        Write-Output -InputObject ('WMI connection failed to ' + $computerName + '.')
    }
}

# Get support bundle from an ESXi 5.5 or newer host using HTTP request method
#
# This script uses HTTP requests and doesn't require PowerCLI
#

# Credential for ESXi web interface
$esxCredential = Get-Credential -Message 'Enter credentials for ESXi web interface'

# List of servers to retrieve support bundles for
$servers = 'C:\Temp\ServersToGetSupportBundleFrom.txt'

# Where to save the output to
$saveToFolder = 'C:\Temp\'

# Run through the servers generating and downloading the support bundles
ForEach ($server in $servers) {
    $dateTime = Get-Date -UFormat '%Y-%m-%d--%H.%M'
    $source = 'https://' + $server +'/cgi-bin/vm-support.cgi'
    $destination = $saveToFolder + 'esx-' + $server + '-' + $dateTime + '.tgz'
    Invoke-WebRequest -Uri $source -OutFile $destination -Credential $esxCredential
}

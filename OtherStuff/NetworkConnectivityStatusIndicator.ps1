# Script to carry out the same tests that Windows 10 Network Location Awareness (NLA) uses via Network Connectivity Status Indicator (NCSI)
# to establish whether a computer has an Internet connection or not.
#
# Useful for troubleshooting when a computer shows "No connectivity" or "Limited Internet access" for no apparent reason.
#

# FQDN for first DNS lookup
$msftConnectTestFqdn = 'www.msftconnecttest.com'

# Web URL for the connecttest.txt file
$webRequestUrl = 'http://www.msftconnecttest.com/connecttest.txt'

# Content expected within the connecttest.txt file
$webRequestContent = 'Microsoft Connect Test'

# FQDN for second DNS lookup
$msftNcsiFqdn = 'dns.msftncsi.com'

# IP address expected for second DNS lookup
$msftNcsiIp = '131.107.255.255'

# Carry out the first DNS lookup
try {
    $null = Resolve-DnsName -Name $msftConnectTestFqdn -ErrorAction Stop
    Write-Output -InputObject ('Lookup of ' + $msftConnectTestFqdn + ' sucessful.')
}
catch {
    Write-Output -InputObject ('Lookup of ' + $msftConnectTestFqdn + ' failed.')
}

# Retrieve the content from the connecttest.txt file and check it is correct
try {
    $webRequest = Invoke-WebRequest -Uri $webRequestUrl -ErrorAction Stop
    if ($webRequest.Content -eq $webRequestContent) {
        Write-Output -InputObject ('Content of ' + $webRequestUrl + ' (' + $webRequest.Content + ') correct.')
    }
    else {
        Write-Output -InputObject ('Content of ' + $webRequestUrl + ' (' + $webRequest.Content + ') incorrect. Should be: ' + $webRequestContent + '.')
    }
}
catch {
    Write-Output -InputObject ('Retrival of ' + $webRequestUrl + ' failed.')
}

# Carry out second DNS lookup and confirm correct IP is returned
try {
    $msftNcsi = Resolve-DnsName -Name $msftNcsiFqdn -Type 'A' -ErrorAction Stop
    Write-Output -InputObject ('Lookup of ' + $msftNcsiFqdn + ' sucessful.')
    if ($msftNcsi.IPAddress -eq $msftNcsiIp) {
        Write-Output -InputObject ('Correct IP address (' + $msftNcsi.IPAddress + ') returned for ' + $msftNcsiFqdn + '.')
    }
    else {
        Write-Output -InputObject ('Incorrect IP address (' + $msftNcsi.IPAddress + ') returned for ' + $msftNcsiFqdn + '. Should be: ' + $msftNcsiIp + '.')
    }
}
catch {
    Write-Output -InputObject ('Lookup of ' + $msftNcsiFqdn + ' failed.')
}

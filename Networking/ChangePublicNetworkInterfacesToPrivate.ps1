# Find network adaptors with type of public and change them to type private if they have a private IPv4 address
#
# Matches private IP ranges:
#
# 127.0.0.0 - 127.*.*.*
# 169.254.0.0 - 169.254.*.*
# 10.0.0.0 - 10.*.*.*
# 172.16.0.0 - 172.31.*.*
# 192.168.0.0 - 192.168.*.*
#
# Needs to be run elevated

# Find all network connections that are set to type public
$publicConnections = Get-NetConnectionProfile -NetworkCategory 'Public'

# Work through the connections found
foreach ($publicConnection in $publicConnections) {

    # Get the IPv4 address for the connection
    $adapterIPAddress = (Get-NetIPAddress -InterfaceAlias $publicConnection.InterfaceAlias -AddressFamily IPv4).IPAddress

    # If the IPv4 address matches one of the private ranges, set the connection type to private
    if ($adapterIPAddress -match '^(127\.)|(169\.254\.)|(10\.)|(172\.(1[6-9]|2[0-9]|3[0-1])\.)|(192\.168\.)') {
        Set-NetConnectionProfile -InterfaceAlias $publicConnection.InterfaceAlias -NetworkCategory 'Private'
    }
}

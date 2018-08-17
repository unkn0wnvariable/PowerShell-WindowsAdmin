# A simple script to create a split-scope DHCP scope on Windows DHCP server
#
# This is only designed to work for class C /24 subnets.
#

# Variables...

# What are our DHCP servers called?
$dhcpServer1 = 'dhcp-server1'
$dhcpServer2 = 'dhcp-server2'

# The network address
$scopeID = '192.168.1.0'

# The starting address of our DHCP pool
$scopeStart = '192.168.1.20'

# The ending address of our DHCP pool
$scopeEnd = '192.168.1.250'

# Router IP
$routerIP = '192.168.1.1'

# Broadcast IP (this is always the last IP in the range)
$broadcastIP = '192.168.1.255'

# Subnet mask
$subnetMask = '255.255.255.0'

# How long the leases last for
$leaseDuration = '8.00:00:00'

# Name of the scope
$scopeName = 'VLAN 1'

# Description for the scope
$scopeDescription = 'Our first VLAN'

# Last IP to serve from server 1
$splitPoint = '199'


# Lets create stuff!

# Get the first 3 segments of the IP address
$scopeBase = $scopeStart.Split('.')[0] + '.' + $scopeStart.Split('.')[1] + '.' + $scopeStart.Split('.')[3]

# Create the end point for the primary scope and the start point for the secondary scope
$splitScopePrimaryPoint = $scopeBase + '.' + $splitPoint
$splitScopeSecondaryPoint = $scopeBase + '.' + ([int]$splitPoint + 1).ToString()

# Create the scope on each server with a 500ms delay on the secondary server
Add-DhcpServerv4Scope -ComputerName $dhcpServer1 -StartRange $scopeStart -EndRange $scopeEnd -SubnetMask $subnetMask -Type Dhcp -LeaseDuration $leaseDuration -Name $scopeName -State InActive -Description $scopeDescription
Add-DhcpServerv4Scope -ComputerName $dhcpServer2 -StartRange $scopeStart -EndRange $scopeEnd -SubnetMask $subnetMask -Type Dhcp -LeaseDuration $leaseDuration -Name $scopeName -State InActive -Description $scopeDescription -Delay 500

# Set the router IP option
Set-DhcpServerv4OptionValue -ComputerName $dhcpServer1 -ScopeId $scopeID -Router $routerIP
Set-DhcpServerv4OptionValue -ComputerName $dhcpServer2 -ScopeId $scopeID -Router $routerIP

# Add an exclusion for the router IP
Add-DhcpServerv4ExclusionRange -ComputerName $dhcpServer1 -ScopeId $scopeID -StartRange $routerIP -EndRange $routerIP
Add-DhcpServerv4ExclusionRange -ComputerName $dhcpServer2 -ScopeId $scopeID -StartRange $routerIP -EndRange $routerIP

# Create exclusion ranges to split the scope between the servers
Add-DhcpServerv4ExclusionRange -ComputerName $dhcpServer1 -ScopeId $scopeID -StartRange $splitScopePrimaryPoint -EndRange $scopeEnd
Add-DhcpServerv4ExclusionRange -ComputerName $dhcpServer2 -ScopeId $scopeID -StartRange $scopeStart -EndRange $splitScopeSecondaryPoint

# Set the broadcast IP option
Set-DhcpServerv4OptionValue -ComputerName $dhcpServer1 -ScopeId $scopeID -OptionId 28 -Value $broadcastIP
Set-DhcpServerv4OptionValue -ComputerName $dhcpServer2 -ScopeId $scopeID -OptionId 28 -Value $broadcastIP

# Set the scopes to active (they are created disabled)
Set-DhcpServerv4Scope -ComputerName $dhcpServer1 -ScopeId $scopeID -State Active
Set-DhcpServerv4Scope -ComputerName $dhcpServer2 -ScopeId $scopeID -State Active

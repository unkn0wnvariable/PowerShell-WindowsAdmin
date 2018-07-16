# Script to remove multiple options from multiple DHCP servers
#
# Requires the DHCP module that is part of Windows RSAT
#

# Import the DHCP Server module
Import-Module DhcpServer


# Which servers to remove options from?
$dhcpServers = @('','')

# Which options to remove?
$optionsToRemove = @('','')


# Iterate through the DHCP servers
foreach ($dhcpServer in $dhcpServers)
{
    # Get existing server options
    $serverOptions = Get-DhcpServerv4OptionValue -ComputerName $dhcpServer

    # Get DHCP scopes from server
    $dhcpScopes = Get-DhcpServerv4Scope -ComputerName $dhcpServer

    # Iterate through options to be removed
    foreach ($optionToRemove in $optionsToRemove)
    {
        # If the option is in the server options, then remove it.
        if ($optionToRemove -in $serverOptions.OptionId)
        {
            Write-Output -InputObject ('Removing server option ' + $optionToRemove + ' from ' + $dhcpServer + '.'  )
            Remove-DhcpServerv4OptionValue -ComputerName $dhcpServer -OptionId $optionToRemove
        }

        # Iterate through the DHCP scopes
        foreach ($dhcpScope in $dhcpScopes)
        {
            # Get options set up on scope
            $scopeOptions = Get-DhcpServerv4OptionValue -ComputerName $dhcpServer -ScopeId $dhcpScope.ScopeId

            # If the option to be removed is present, then remove it
            if ($optionToRemove -in $scopeOptions.OptionId)
            {
                Write-Output -InputObject ('Removing scope option ' + $optionToRemove + ' from ' +  $dhcpScope.ScopeId + ' on ' + $dhcpServer + '.'  )
                Remove-DhcpServerv4OptionValue -ComputerName $dhcpServer -ScopeId $dhcpScope.ScopeId -OptionId $optionToRemove
            }
        }
    }
}

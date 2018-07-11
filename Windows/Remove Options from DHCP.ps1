# Script to remove multiple options from multiple DHCP servers
#
# Requires the DHCP module that is part of Windows RSAT
#

# Import the DHCP Server module
Import-Module DhcpServer

# Create array containing all DHCP servers to have options removed
$dhcpServers = @('','')

# Create array containing options to be removed
$optionsToRemove = @('','')

# Iterate through the DHCP servers
ForEach ($dhcpServer in $dhcpServers)
{
    # Get existing server options
    $serverOptions = Get-DhcpServerv4OptionValue -ComputerName $dhcpServer

    # Get DHCP scopes from server
    $dhcpScopes = Get-DhcpServerv4Scope -ComputerName $dhcpServer

    # Iterate through options to be removed
    ForEach ($optionToRemove in $optionsToRemove)
    {
        # If the option is in the server options, then remove it.
        If ($optionToRemove -in $serverOptions.OptionId)
        {
            Write-Output -InputObject ('Removing server option ' + $optionToRemove + ' from ' + $dhcpServer + '.'  )
            Remove-DhcpServerv4OptionValue -ComputerName $dhcpServer -OptionId $optionToRemove
        }

        # Iterate through the DHCP scopes
        ForEach ($dhcpScope in $dhcpScopes)
        {
            # Get options set up on scope
            $scopeOptions = Get-DhcpServerv4OptionValue -ComputerName $dhcpServer -ScopeId $dhcpScope.ScopeId

            # If the option to be removed is present, then remove it
            If ($optionToRemove -in $scopeOptions.OptionId)
            {
                Write-Output -InputObject ('Removing scope option ' + $optionToRemove + ' from ' +  $dhcpScope.ScopeId + ' on ' + $dhcpServer + '.'  )
                Remove-DhcpServerv4OptionValue -ComputerName $dhcpServer -ScopeId $dhcpScope.ScopeId -OptionId $optionToRemove
            }
        }
    }
}

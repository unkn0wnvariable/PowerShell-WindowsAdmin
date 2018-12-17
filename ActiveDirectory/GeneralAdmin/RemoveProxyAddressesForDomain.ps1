# Script to bulk remove email proxy addresses from AD users
#

# Which domains are we removing?
$domainsToRemove = @('','')

# Import the Active Directory module
Import-Module -Name ActiveDirectory

# Get administrative level credentials for Active Directory
$adCredentials = Get-Credential -Message 'Enter your Active Directory administrator credentials'

### Remove the domain from users ###

# Get All Mailboxes
$allUsers = Get-ADUser -Filter * -Properties ProxyAddresses | Sort-Object -Property samAccountName

# Remove alias from each mailbox
foreach ($user in $allUsers) {
    $redundantAddresses = @()
    foreach ($domainToRemove in $domainsToRemove) {
        $redundantAddresses += (($user.proxyAddresses -split ',' | Where-Object {$_ -match $domainToRemove}))
    }
    foreach ($redundantAddress in $redundantAddresses) {
        Write-Output -InputObject ('Removing addresses ' + $redundantAddress + ' from user ' + $user.Name)
        Set-ADUser -Identity $user.SamAccountName -Remove @{ProxyAddresses=$redundantAddress} -Credential $adCredentials -Confirm:$false
    }
}

###

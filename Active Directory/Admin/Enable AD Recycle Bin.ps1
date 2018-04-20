# Script to enable the full recycle bin in Active Directory
#
# Requires the Active Directory component of RSAT to be installed.
#

# Import the Active Directory module
Import-Module -Name ActiveDirectory

# Get administrative level credentials for Active Directory
$adCredentials = Get-Credential -Message 'Enter your Active Directory administrator credentials'

# Find the domain controller which holds the schema master role
$schemaMaster = (Get-ADDomainController -Filter * | Where-Object {$_.OperationMasterRoles -contains 'SchemaMaster'}).Name

# Get the necessary information about the domain 
$adDomain = Get-ADDomain
$distinguishedName = $adDomain.DistinguishedName
$domainName = $adDomain.DNSRoot

# Establish the distingushed name for the recycle bin feature
$recycleBinDN = 'CN=Recycle Bin Feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,' + $distinguishedName

# Enable the recycle bin
Enable-ADOptionalFeature -Server $schemaMaster –Identity $recycleBinDN –Scope ForestOrConfigurationSet –Target $domainName -Credential $adCredentials -Confirm:$false

# Confirm the feature has been enabled
$enabledScopes = (Get-ADOptionalFeature -Filter 'name -like "Recycle Bin Feature"' -Credential $adCredentials).EnabledScopes
Write-Output -InputObject ('The following list should contain NTDS Settings for all DCs, plus the Configuration Partitions scope:')
Write-Output -InputObject $enabledScopes

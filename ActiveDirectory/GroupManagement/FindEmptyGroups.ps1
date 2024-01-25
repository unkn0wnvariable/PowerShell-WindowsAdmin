# Export a list of empty AD groups to CSV file
#

# Output file path
$outputFile = 'C:\Temp\EmptyGroups.csv'

# Provide the FQDN for a domain controller (if this is left blank the script will prompt for it)
$domainController = ''

# Any OUs to exclude, like the ones with default groups in
$excludedOUs = @(
    'ad.sis.tv/Builtin',
    'ad.sis.tv/Microsoft Exchange Security Groups'
)

# Any specific groups to exclude, like default ones for AD, IIS, Exchange, etc, that could be empty but shouldn't be deleted
$excludedGroups = @(
    'Allowed RODC Password Replication Group',
    'Cloneable Domain Controllers',
    'ConfigMgr Remote Control Users',
    'CSAdministrator',
    'DHCP Administrators',
    'DHCP Users',
    'DnsAdmins',
    'DnsUpdateProxy',
    'Domain ACSAdmin',
    'Domain ACSGuest',
    'Domain ACSUsers',
    'Domain Computers',
    'Domain Controllers',
    'Domain Guests',
    'Enterprise Key Admins',
    'Enterprise Read-only Domain Controllers',
    'Exchange Creators',
    'HelpServicesGroup',
    'IIS_WPG',
    'Key Admins',
    'Protected Users',
    'Read-only Domain Controllers',
    'RTC Local Administrators',
    'RTC Local Read-only Administrators',
    'RTC Local User Administrators',
    'RTCABSDomainServices',
    'RTCArchivingDomainServices',
    'RTCComponentUniversalServices',
    'RTCDomainUserAdmins',
    'RTCHSDomainServices',
    'RTCHSUniversalServices',
    'RTCProxyDomainServices',
    'RTCUniversalServerAdmins',
    'RTCUniversalUserAdmins',
    'Session Directory Computers',
    'TelnetClients'
)

# If domain controller FQDN hasn't been provided, request it
if ($domainController.Length -eq 0) {
    $domainController = Read-Host -Prompt 'Enter the FQDN of a domain controller';
}

# Get credentials and set variable to use for splatting server and credential arguments
$serverDetails = @{
    Server     = $domainController
    Credential = Get-Credential -Message 'Enter credentials for an account with the necessary permissions'
}

# Import the AD module
Import-Module -Name ActiveDirectory

# Get all groups with "no members" (this will include any groups that have only disabled accounts in them)
$allGroups = Get-ADGroup -Filter * -Properties Name, Members, CanonicalName, GroupCategory, GroupScope, Description @serverDetails | Where-Object {$_.Members.Count -eq '0'}

# Filter the groups list to remove our exclusions
$allGroups = $allGroups | Where-Object { $_.CanonicalName.Substring(0, $_.CanonicalName.lastIndexOf('/')) -notin $excludedOUs -and $_.Name -notin $excludedGroups }

# Check the remaining groups for members that are disabled accounts and filter those out - this is slow, very slow
$i = 0
$emptyGroups = @()
foreach ($group in $allGroups) {
    Write-Progress -Activity 'Checking members for...' -Status $group.Name -PercentComplete ((++$i / $allGroups.Count) * 100)
    $groupMembers = Get-ADGroupMember -Identity $group @serverDetails
    if ($groupMembers.Count -eq 0) {
        $emptyGroups += $group
    }
}

# Output the final list of empty groups to a CSV file
$emptyGroups | Select-Object Name, CanonicalName, GroupCategory, GroupScope, Description | Sort-Object -Property CanonicalName | Export-Csv $outputFile -NoTypeInformation

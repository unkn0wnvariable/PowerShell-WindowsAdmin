# Get all AD user accounts with a last logon date older than a cut-off we specify in days
#

# Import the Active Directory module - requires AD RSAT tools to be installed
Import-Module ActiveDirectory

# How long ago should we report on for the last login?
$cutOffDate = (Get-Date).AddDays('-60')

# Where should we output the results to?
$outputFile = 'C:\Temp\LastLoginNoneAndStale.csv'

# Get server and credentials for a domain controller to connect to
$domainServer = Read-Host -Prompt 'Enter the FQDN of a domain controller'
$domainCredential = Get-Credential -Message 'Enter credentials for an account with the necessary permissions'

# Get all users from AD
$allUsers = Get-ADUser -Filter { Enabled -eq 'True' } -Properties Name, SamAccountName, UserPrincipalName, EmailAddress, lastLogon -Server $domainServer -Credential $domainCredential

# Find all users with a last logon date older than the cut off set above
$outputDetails = @()
foreach ($user in $allUsers) {
    $userLastLogon = [datetime]::FromFileTimeUtc($user.lastLogon)
    if ($userLastLogon -lt $cutOffDate) {
        if ($userLastLogon -eq '01/01/1601 00:00:00') { $userLastLogon = 'Never' } # replaces the default date for no-login with a more obvious 'Never'
        $outputDetails += [PSCustomObject]@{
            'Name'              = $user.Name;
            'SamAccountName'    = $user.SamAccountName;
            'UserPrincipalName' = $user.UserPrincipalName;
            'EmailAddress'      = $user.EmailAddress;
            'lastLogon'         = $userLastLogon.ToString();
        }
    }
}

# Export results to CSV file
$outputDetails | Export-Csv -Path $outputFile

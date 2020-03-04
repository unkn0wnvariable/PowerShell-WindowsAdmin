# Bulk create new users from CSV
#
# CSV file is expected to have columns titled Name,Description,UPNDomain,Groups,OU
# Groups should be one or more entries seperated with a semicolon (;).
#

# Where is the CSV file?
$filePath = 'C:\Temp\NewAccounts.csv'

# Import the Active Directory module
Import-Module -Name ActiveDirectory

# Import CSV containing details of users to create
$newUsers = Import-Csv -Path $filePath

# Get administrative level credentials for Active Directory
if ($null -eq $adCredentials) {
    $adCredentials = Get-Credential -Message 'Enter your Active Directory administrator credentials'
}

# Create new users in AD
$createdUsers = @()
foreach ($newUser in $newUsers) {
    $accountName = $newUser.Username.ToLower()
    $accountPassword = ([system.web.security.membership]::GeneratePassword(16, 1))
    $securePassword = ConvertTo-SecureString -String $accountPassword -AsPlainText -Force
    $userUPN = $accountName + '@' + $newUser.UPNDomain
    
    $newUserValues = @{
        Name              = $newUser.Name;
        DisplayName       = $newUser.Name;
        SamAccountName    = $accountName;
        UserPrincipalName = $userUPN;
        Description       = $newUser.Description;
        AccountPassword   = $securePassword;
        Path              = $newUser.OU
        Enabled           = $true
    }

    $null = New-ADUser @newUserValues -Credential $adCredentials

    $groups = $newUser.Groups.Split(';')
    foreach ($group in $groups) {
        $groupSID = (Get-ADGroup -Filter { Name -eq $group }).SID
        $null = Add-ADGroupMember -Identity $groupSID -Members $accountName -Credential $adCredentials
    }

    $createdUsers += [PSCustomObject]@{
        Username = $accountName
        Password = $accountPassword
    }
}

Write-Output -InputObject 'The following user accounts have been created:'
Write-Output -InputObject ($createdUsers | Format-List)

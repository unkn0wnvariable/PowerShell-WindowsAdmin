# Remove a duplicate 365 account created by a faulty sync and reconnect
# the orphaned 365 user to the AD account.
# 

# Get correct and incorrect account details
$adUsername = Read-Host -Prompt 'Enter username for AD account'
$msolIncorrectUPN = Read-Host -Prompt 'Enter UPN for the duplicate object in MSOL'

# Connect to MS Online
Connect-MsolService

# Get AD user account
$adObject = Get-ADUser -Identity $adUsername

# Get correct UPN from AD account
$msolCorrectUPN = $adObject.UserPrincipalName

# 
try {
    Get-MsolUser -UserPrincipalName $msolCorrectUPN -ErrorAction Stop

    Remove-MSOLuser -UserPrincipalName $msolIncorrectUPN
    Remove-MSOLuser -UserPrincipalName $msolIncorrectUPN -RemoveFromRecycleBin

    $adGuid = $adObject.ObjectGuid
    $immutableID = [System.Convert]::ToBase64String($adGuid.ToByteArray())

    Set-MSOLuser -UserPrincipalName $msolCorrectUPN -ImmutableID $immutableID
}
catch {
    Write-Host 'No account found in Azure AD matching the UPN for that AD account.'
}

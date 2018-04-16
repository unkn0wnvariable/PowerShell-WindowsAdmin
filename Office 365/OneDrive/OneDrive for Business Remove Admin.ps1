# Remove a collection administrator from your users' OneDrive for Business accounts
#
# Requires the Sharepoint Online PowerShell module to be installed
#

# The name of your Office 365 organization
# This can be found in your Sharepoint URL before the '-my', eg: https://thecompany-my.sharepoint.com/
$orgName=''

# The UPN of the account you wish to add as a secondary admin
$secondaryAdminUPN = ''

# The list of UPNs for the accounts you wich to add the secondary admin to
$userList = @('','')

# Connect to Sharepoint Online
$spoServiceURL = 'https://' + $orgName + '-admin.sharepoint.com'
Import-Module 'C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell' -DisableNameChecking
Connect-SPOService -Url $spoServiceURL

# Create the base URL for OneDrive for Business
$spoBaseURL = 'https://' + $orgName + '-my.sharepoint.com/personal/'

# Add secondary admin to each user in the list
ForEach ($userUPN in $userList) {
    $spoURL = $spoBaseURL + ($userUPN.ToLower() -replace "[@.]", "_")
    Set-SPOUser -Site $spoURL -LoginName $secondaryAdminUPN -IsSiteCollectionAdmin $false -ErrorAction:Continue
    Remove-SPOUser -Site $spoURL -LoginName $secondaryAdminUPN
}

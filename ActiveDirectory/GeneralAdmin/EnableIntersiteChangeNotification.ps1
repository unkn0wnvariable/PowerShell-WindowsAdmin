# Script to enable change notification on inter-site links.
#
# Currently this will either set to 1 or stop if the value is already set to something.
# There is theoretically a way to set this even when the value is non-null using bor, but I need
# to test what happens if the value set is already enabling change notification.
#

# Get AD admin credentials
$adminCreds = Get-Credential

# Get all the site links
$siteLinks = Get-ADReplicationSiteLink -Filter * -Properties Name,options -Credential $adminCreds

# Run through the site links checking them and setting them to 1 if the value is null
foreach ($siteLink in $siteLinks) {
    if ($null -eq $siteLink.options) {
        Set-ADReplicationSiteLink -Identity $siteLink.Name -Replace @{'options' = 1} -Credential $adminCreds
        Write-Output ('Options on site link ' + $siteLink.Name + ' set to 1 (enable Change Notification).')
    }
    elseif ($siteLink.options -eq 1) {
        Write-Output ('Options on site link ' + $siteLink.Name + ' is already set to 1 (enable Change Notification).')
    }
    else {
        Write-Output ('Options on site link ' + $siteLink.Name + ' is already set to a value other than 1.')
    }
}

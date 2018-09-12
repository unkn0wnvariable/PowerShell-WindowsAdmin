# Script to add devices to a collection in SCCM
#
# Requires the SCCM admin console to be installed for the PowerShell module
#

# Where is the list of devices to add?
$deviceListFile = ''

# What collection are we adding them to?
$collectionName = ''

# What is the name of the SCCM site?
$siteName = ''

# Import the SCCM Module
Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)

# Get the contents of the device list file
$deviceList = Get-Content $deviceListFile

# Switch to the site path
$sitePath = $siteName + ':'
Set-Location -Path $sitePath

# Get the ID for the collection we want to add to
$collectionID = (Get-CMCollection -Name $collectionName).CollectionID

# Add the devices to the collection
foreach ($device in $deviceList) {
    $deviceID = (Get-CMDevice -Name $device).ResourceID
    Add-CMDeviceCollectionDirectMembershipRule -CollectionID $collectionID -ResourceId $deviceID
}

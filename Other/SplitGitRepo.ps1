# Script to split a Git repo sub folder into a new repo
#

<#
Requires Git for Windows to be installed from here:
https://git-scm.com/downloads

This pretty much just carrying out the process documented here:
https://help.github.com/articles/splitting-a-subfolder-out-into-a-new-repository/

Make sure you have a backup before use!
#>

# Local path to the current repo
$currentRepo = ''

# Local path to create the new repo
$newRepo = ''

# Name of the subfolder to split away
$subfolder = ''

# New origin URL from site to publish to
$newOriginURL = ''

# Name of the branch
$branchName = ''

# Clone the repo and move into it
Invoke-Expression ('git clone ' + $currentRepo + ' ' + $newRepo)
Set-Location $newRepo

# Strip out everything except the subfolder to be kept
Invoke-Expression ('git filter-branch --prune-empty --subdirectory-filter ' + $subfolder + ' ' + $branchName)

# Set the origin URL to the new publish point
Invoke-Expression ('git remote set-url origin ' + $newOriginURL)

# Retrive the push and fetch origin URLs for the new repository
$pushOrigin = ((Invoke-Expression ('git remote -v') | Where-Object {$_ -like '*push*'}) -split '\t| +')[1]
$fetchOrigin = ((Invoke-Expression ('git remote -v') | Where-Object {$_ -like '*fetch*'}) -split '\t| +')[1]

# Check the origin URLs have updated correctly, if not display a message
$urlsOK = $false
if (($pushOrigin -eq $newOriginURL) -and ($fetchOrigin -eq $newOriginURL)) {
    $urlsOK = $true
}
else {
    Write-Output -InputObject 'Origin URLs have not updated correctly, operation will not complete.'
}

# If the origin URL has been updated OK then push to the new origin
if ($urlsOK) {
    Invoke-Expression ('git push -u origin ' + $branchName)
}

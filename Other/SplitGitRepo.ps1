# Script to split a Git repo sub folder into a new repo
#

<#
Requires Git for Windows to be installed from here:
https://git-scm.com/downloads

This pretty much just carrying out the process documented here:
https://help.github.com/articles/splitting-a-subfolder-out-into-a-new-repository/
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

# Run the commands
Invoke-Expression ('git clone ' + $currentRepo + ' ' + $newRepo)
Set-Location $newRepo
Invoke-Expression ('git filter-branch --prune-empty --subdirectory-filter ' + $subfolder + ' ' + $branchName)
Invoke-Expression ('git remote set-url origin ' + $newOriginURL)
Invoke-Expression ('git push -u origin ' + $branchName)

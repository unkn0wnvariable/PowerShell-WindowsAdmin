# Script to get all DFS targets and the shares to which they point
#

# Ask for the DFS root share URI.
$dfsRoot = Read-Host -Prompt 'Enter path to DFS root share. Eg: \\domain\shared'

# Get all the shares (children) wihtin the DFS root share
$dfsShares = Get-ChildItem -Path $dfsRoot

# Create blank hash table for DFS share targets
$dfsTargets = @()

# Iterate through the DFS shares getting their targets
foreach ($dfsShare in $dfsShares) {
    $sharePath = $dfsRoot + '\' + $dfsShare.Name
    $dfsTargets += Get-DfsnFolderTarget -Path $sharePath | Select-Object Path,TargetPath
}

# Output table of DFS shares and where they point to.
$dfsTargets | Format-Table -AutoSize

# List DFS targets

$dfsRoot = Read-Host -Prompt 'Enter path to DFS root share. Eg: \\domain\shared'

$dfsShares = Get-ChildItem -Path $dfsRoot

ForEach ($dfsShare in $dfsShares) {
    $sharePath = $dfsRoot + '\' + $dfsShare.Name
    Get-DfsnFolderTarget -Path $sharePath | Select Path,TargetPath
}

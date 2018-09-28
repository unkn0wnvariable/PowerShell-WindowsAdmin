# Script to calculate the staging quota requirements for all DFS replicated shares
#

# Where to save the results to?
$outputFile = 'C:\Temp\DFSRStagingSizes.csv'

# Get all replicated folders from DFS
$replicatedFolders = Get-DfsReplicatedFolder

# Create a blank table to hold the objects
$dfsnDetails = @()

# Iterate through the shares
foreach ($replicatedFolder in $replicatedFolders) {
    # Get the top 32 biggest files from the share
    $biggestFiles = Get-ChildItem -Path $replicatedFolder.DfsnPath -Recurse | Sort-Object -Property Length -Descending | Select-Object -First 32

    # Sum the sizes of the top 32 files
    $filesSum = $biggestFiles | Measure-Object -Property Length –Sum

    # Convert the value to MB and round up
    $stagingQuotaMB = [math]::Ceiling($filesSum.Sum / 1MB)
    
    # Create an object with the details in
    $dfsnDetails += [pscustomobject]@{
        'FolderName' = $replicatedFolder.FolderName;
        'DfsnPath' = $replicatedFolder.DfsnPath;
        'StagingQuotaMB' = $stagingQuotaMB;
    }
}

# Output the details to a CSV file
$dfsnDetails | Export-Csv -Path $outputFile

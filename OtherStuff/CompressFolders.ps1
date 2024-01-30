# Just a simple script to compress a bunch of subfolders into seperate zip files
#

# What is the root folder path that the subfolders are under?
$rootPath = ''

# Get a list of the full paths to each subfolder
$folders = (Get-ChildItem -Path $rootPath).FullName

# Compress all the subfolders to zip files
foreach ($folder in $folders) {
    $outputFile = $folder + '.zip'
    Compress-Archive -Path $folder -DestinationPath $outputFile -CompressionLevel 'Optimal'
}

# Rename files using Git Move
#

$path = ''

# Get files in folder
$files = Get-ChildItem -Path $path

# Iterate through files removing spaces from the name and converting the extension to lower case
ForEach ($file in $files)
{
    $newName = ($file.Name.Split('.')[0]) -replace ' '
    $newExtension = (($file.Name.Split('.')[1]).ToLower())
    $newFileName = $newName + '.' + $newExtension

    Set-Location $path
    git mv $file.Name $newFilename
}

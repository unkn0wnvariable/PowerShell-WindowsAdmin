# Rename files using Git Move
#

# Set the path where the files to be renamed are
$path = ''

# Get files in folder
$files = Get-ChildItem -Path $path

# Iterate through files removing spaces from the name and converting the extension to lower case
foreach ($file in $files)
{
    # Split the file name away and replace spaces with hypens
    $newName = ($file.Name.Split('.')[0]) -replace ' ','-'

    # Split the file extension away and convert to lower case
    $newExtension = (($file.Name.Split('.')[1]).ToLower())

    # Recombine new file name and extension
    $newFileName = $newName + '.' + $newExtension

    # If the filename needs to be changed, move the file with git
    if ($newFileName -ne $file.Name)
    {
        Set-Location $path
        Invoke-Expression ('git mv "' + $file.Name + '" "' + $newFilename +'"')
    }
}

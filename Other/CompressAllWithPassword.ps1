# Script to compress all files in a folder to seperate archives
#

# Where are the files to be compressed (trailing \ required)?
$pathToFiles = 'C:\Temp\FilesToCompress\'

# What file extension are we compressing? (E.g.: *.log)
$compressMatching = '*.log'

# Are we using a password? If so put it in here.
$filePassword = ''

# Where is the 7z executable?
$pathTo7zip = 'C:\Program Files\7-Zip\7z.exe'

# Get a list of the files from the folder
$filesToCompress = (Get-ChildItem -Path $pathToFiles | Where-Object {$_.Name -like $compressMatching}).Name

# Run through the files
foreach ($fileToCompress in $filesToCompress) {

    # Create the new file name for the archive
    $compressedFile = $fileToCompress.Split('.')[0] + '.zip'

    # If the password variable was set then use it, if not don't.
    if ($filePassword.Length -gt 0) {
        $commandToRun = '& "' + $pathTo7zip + '" -p"' + $filePassword + '" a "' + $pathToFiles + $compressedFile + '" "' + $pathToFiles + $fileToCompress + '"'
    }
    else {
        $commandToRun = '& "' + $pathTo7zip + '" a "' + $pathToFiles + $compressedFile + '" "' + $pathToFiles + $fileToCompress + '"'
    }

    # Run the command
    Invoke-Expression -Command $commandToRun
}

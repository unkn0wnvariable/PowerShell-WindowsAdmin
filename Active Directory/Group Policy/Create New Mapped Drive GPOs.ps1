# Use the CSV file from the Logon Script Mapped Drives script to do stuff...
#

# Set input file path and name.
$inputFile = 'C:\Temp\New-GPO-Mapped-Drives.csv'

# Import from CSV file
$existingMappedDrives = Import-Csv -Path $inputFile

# Test paths and output a list of those which are not valid.
ForEach ($existingMappedDrive in $existingMappedDrives) {
    #If (!(Test-Path -Path $existingMappedDrive.MappedPath)) {
    #    Write-Host ($existingMappedDrive.MappedPath + ' referenced in ' + $existingMappedDrive.GPOName + ' is not online.')
    #}
    $existingMappedDrive
    If ($existingMappedDrive.Exists) {
        $shareServer = [regex]::match($existingMappedDrive.MappedPath,'[^\\]+').value
        $mappedDrive = $existingMappedDrive.DriveLetter.ToLower()
        Write-Host ($existingMappedDrive.MappedPath + ' on server ' + $shareServer + ' to drive ' + $mappedDrive + ' referenced in ' + $existingMappedDrive.GPOName + '.')
    }
}

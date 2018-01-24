# Export a list of all GPO's to a HTML files.
#

# Set output file path and name.
$outputFolder = 'C:\Temp\GPO HTML Reports\'

# Check output folder exists and create it if it doesn't
If (!(Test-Path -Path $outputFolder)) {New-Item -Path $outputFolder -ItemType Directory}

# Get all GPO's and export to CSV
$gpos = Get-GPO -All

# Get reports to HTML files
ForEach ($gpo in $gpos) {
    $outputFile = $outputFolder + $gpo.DisplayName + '.html'
    If (Test-Path -Path $outputFile) {Remove-Item -Path $outputFile}
    Get-GPOReport -Name $gpo.DisplayName -ReportType Html -Path $outputFile
}

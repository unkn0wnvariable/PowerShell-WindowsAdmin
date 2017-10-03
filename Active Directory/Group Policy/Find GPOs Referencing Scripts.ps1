# Find all GPO's which are calling logon scripts for users.
# Output the list to a CSV file.
#

# Set output file path and name.
$outputFile = 'C:\Temp\Script-GPOs.csv'

# Check output folder exists and create it if it doesn't
$outputPath = (Split-Path -Path $outputFile)
If (!(Test-Path -Path $outputPath)) {New-Item -Path $outputFolder -ItemType Directory}

# Get reports for all GPO's
# (we do it this way because Get-GPOReport -All -ReportType xml creates an odd array)
$gpoReports = Get-GPO -All | Get-GPOReport -ReportType xml

# If output file already exists, delete it.
If (Test-Path -Path $outputFile) {Remove-Item -Path $outputFile}

# Open CSV file with headings.
$tableHeadings = "GPOName,GPOCommand,LinksTo"
$tableHeadings | Out-File -FilePath $outputFile -Encoding utf8

# Iterate through all GPO's finding those referencing user scripts and add them to the CSV file.
ForEach ($gpoReport in $gpoReports) {
    If (([xml]$gpoReport).GPO.User.ExtensionData.Extension.type -like '*:Scripts') {
        $tableData = ([xml]$gpoReport).GPO.Name + ',' + ([xml]$gpoReport).GPO.User.ExtensionData.Extension.Script.Command + ',' + ([xml]$gpoReport).GPO.LinksTo.SOMPath
        $tableData | Out-File -FilePath $outputFile -Append -Encoding utf8
    }
}

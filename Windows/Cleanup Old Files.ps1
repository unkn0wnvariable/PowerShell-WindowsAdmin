# Old Files Cleanup
#
# Deletes files older than X days.
#
# As you may guess from the comments below, I originally wrote this to clean up IIS log files.
#

# Where are the files? E.g.: C:\inetpub\logs\LogFiles\W3SVC1
$TargetPath= ''

# Enter a wildcard to match the files to. E.g.: *.log
$Wildcard = ''

# How many days do we want to keep? E.g.: 7
$Days = ''

# Work out the date of the oldest file to keep
$LastWrite = (Get-Date).AddDays(-$Days)

# Find all the files that are to be deleted
$Files = Get-Childitem $TargetPath -Include $Wildcard -Recurse | Where-Object {$_.LastWriteTime -le "$LastWrite"}

# Delete the files
ForEach ($File in $Files) {
  If ($File -ne $NULL) {
    Remove-Item $File.FullName | Out-Null
  }
}

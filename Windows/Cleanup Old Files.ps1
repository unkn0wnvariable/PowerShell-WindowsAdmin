# Old Files Cleanup
#
# Deletes files older than X days.
#
# As you may guess from the comments below, I originally wrote this to clean up IIS log files.
#

# Where are the files? E.g.: C:\inetpub\logs\LogFiles\W3SVC1
$targetPaths= @('','')

# Enter a wildcard to match the files to. E.g.: *.log
$wildcard = ''

# How many days do we want to keep? E.g.: 7
$days = ''

# Work out the date of the oldest file to keep
$lastWrite = (Get-Date).AddDays(-$days)

# Find all the files that are to be deleted
foreach ($targetPath in $targetPaths) {
  $files = Get-Childitem $targetPath -Include $wildcard -Recurse | Where-Object {$_.LastWriteTime -le "$lastWrite"}

  # Delete the files
  foreach ($file in $files) {
    if ($file -ne $NULL) {
      Remove-Item $file.FullName | Out-Null
    }
  }
}

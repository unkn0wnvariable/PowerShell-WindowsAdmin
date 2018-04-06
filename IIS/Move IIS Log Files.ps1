# Script to move the IIS log files to a new location.
#
# There is, or at least was, no easy way to do this from the IIS GUI
#
#

# Where do we want the logs to be?
$logFileDirectory = 'I:\Logs\LogFiles'
$failedRequestsLoggingDirectory = 'I:\Logs\FailedReqLogFiles'

# Where are they now?
$oldLogFilesDirectory = 'C:\inetpub\logs'

# Import the IIS module
Import-Module WebAdministration

# Get all the sites served by IIS
$sites = Get-ChildItem -Path iis:\sites\*

# Update the log file location for each site
ForEach($site in $sites) {
    Set-ItemProperty IIS:\Sites\$($site.Name) -name logFile.directory -value $logFileDirectory
    Set-ItemProperty IIS:\Sites\$($site.Name) -name traceFailedRequestsLogging.directory -value $failedRequestsLoggingDirectory
}

# Restart IIS gracefully
IISReset

# Remove the old log files
Remove-Item $oldLogFilesDirectory -recurse

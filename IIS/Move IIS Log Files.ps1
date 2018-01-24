
$logFileDirectory = 'I:\Logs\LogFiles'
$failedRequestsLoggingDirectory = 'I:\Logs\FailedReqLogFiles'

$oldLogFilesDirectory = 'C:\inetpub\logs'

Import-Module WebAdministration

$sites = Get-ChildItem -Path iis:\sites\*

ForEach($site in $sites) {
    Set-ItemProperty IIS:\Sites\$($site.Name) -name logFile.directory -value $logFileDirectory
    Set-ItemProperty IIS:\Sites\$($site.Name) -name traceFailedRequestsLogging.directory -value $failedRequestsLoggingDirectory
}

IISReset
Remove-Item $oldLogFilesDirectory -recurse

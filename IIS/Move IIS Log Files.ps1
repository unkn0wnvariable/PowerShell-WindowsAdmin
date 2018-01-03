
$logFileDirectory = 'I:\Logs\LogFiles'
$failedRequestsLoggingDirectory = 'I:\Logs\FailedReqLogFiles'

$oldLogFilesDirectory = 'C:\inetpub\logs'

Import-Module WebAdministration
foreach($site in (dir iis:\sites\*)) { Set-ItemProperty IIS:\Sites\$($site.Name) -name logFile.directory -value $logFileDirectory }
foreach($site in (dir iis:\sites\*)) { Set-ItemProperty IIS:\Sites\$($site.Name) -name traceFailedRequestsLogging.directory -value $failedRequestsLoggingDirectory }
IISReset
Remove-Item $oldLogFilesDirectory -recurse

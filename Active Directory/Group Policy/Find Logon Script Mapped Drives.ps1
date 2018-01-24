# Find all mapped drives from GPO logon scripts.
# Output the list to a CSV file.
#
# Requires PS modules provided by Microsoft RSAT

# Set output file path and name.
$outputFile = 'C:\Temp\GPO-Mapped-Drives.csv'

# Check output folder exists and create it if it doesn't
$outputPath = (Split-Path -Path $outputFile)
If (!(Test-Path -Path $outputPath)) {New-Item -Path $outputFolder -ItemType Directory}

# Find the DNS root of the current domain
$domainRoot = (Get-ADDomain -Current LocalComputer).DNSRoot

# Get reports for all GPO's
# Doing it like this because Get-GPOReport -All -ReportType xml creates an odd array and it's nice to see a progress bar
$gpos = Get-GPO -All
$gpoReports = @()
ForEach ($gpo in $gpos) {
    Write-Progress -Activity "Getting report for.." -status $gpo.DisplayName -percentComplete ($gpos.IndexOf($gpo) / $gpos.Count * 100)
    $gpoReports += Get-GPOReport -Name $gpo.DisplayName -ReportType xml
}

# If output file already exists, delete it.
If (Test-Path -Path $outputFile) {Remove-Item -Path $outputFile}

# Initialise the array into which the results will go
$gpoTable = @()

# Iterate through all GPO's retriving the logon script contents and searching for mapped drives creating objects and adding them to the overall array along the way.
# Also locates policies where the script has been attached instead of linked to NETLOGON and tests the mapped drives availability.
# All the while displaying a progress bar because this can take a loooooooooong time.
ForEach ($gpoReport in $gpoReports) {
    Write-Progress -Activity "Getting script and testing mapped drives from.." -status ([xml]$gpoReport).GPO.Name -percentComplete ($gpoReports.IndexOf($gpoReport) / $gpoReports.Count * 100)

    # If the GPO references a script file, carry on.
    If (([xml]$gpoReport).GPO.User.ExtensionData.Extension.type -like '*:Scripts') {

        # Get the path to the logon script
        $logonScriptPath = ([xml]$gpoReport).GPO.User.ExtensionData.Extension.Script.Command

        # If the logon script has been embedded in the policy (doesn't have a path) discover the full path
        If ($logonScriptPath.Split('\').Count -le 1) {
            $gpoGuid = ([xml]$gpoReport).GPO.Identifier.Identifier.'#text'
            $logonScriptPath = "\\$domainRoot\SysVol\$domainRoot\Policies\$gpoGuid\User\Scripts\Logon\$logonScriptPath"
        }

        # Get the contents of the logon script
        $logonScriptFile = Get-Content -Path $logonScriptPath
        ForEach ($line in $logonScriptFile) {
            If ($line -like "*DriveMapper ""*:*" -and $line -notlike "*'*DriveMapper ""*:*" -and $line -notlike "*DriveMapper ""*Drive:*" ) {

                # Get some basic information from the report
                $gpoName = ([xml]$gpoReport).GPO.Name
                $mappedLetter = $line.Split('"')[1]
                $sharePath = $line.Split('"')[3]

                # Get a list of which OU's the GPO is linked to
                If (([xml]$gpoReport).GPO.LinksTo.SOMPath.Count -gt 1) {
                    $gpoLinkedTo = ([xml]$gpoReport).GPO.LinksTo.SOMPath -join '; '
                }
                Else {
                    $gpoLinkedTo = ([xml]$gpoReport).GPO.LinksTo.SOMPath
                }

                # Test if the server hosting the share is available
                $serverOnline = Test-Connection -ComputerName ($sharePath.Split('\')[2]) -Quiet -ErrorAction SilentlyContinue

                # If the server is online, get the FQDN A record for it so we can identify aliases and the IP so we know where it is.
                If ($serverOnline) {
                    $serverDetails = (Resolve-DnsName -Name ($sharePath.Split('\')[2]) | Where-Object {$_.QueryType -eq 'A'})

                    # If more than one A record found, use the hostname from the first entry and create a list of the IP's
                    If ($serverDetails.Count -gt 1) {
                        $serverName = $serverDetails[0].Name
                        $serverIP = $serverDetails.IPAddress -join '; '
                    }
                    Else {
                        $serverName = $serverDetails.Name
                        $serverIP = $serverDetails.IPAddress
                    }

                    # Check to see if the returned hostname matches the hostname from the script 
                    If ($serverName.Split('.')[0] -ne $sharePath.Split('\')[2].Split('.')[0]) {
                        $isAnAlias = $true
                    }
                    Else {
                        $isAnAlias = $false
                    }
                }
                Else {
                    $serverName = 'Unavailable'
                    $serverIP = 'Unavailable'
                    $isAnAlias = $false
                }
                
                # Test if the share is accessible and return either TRUE, FALSE or the error message
                Try {
                    $pathAccessible = Test-Path -Path $sharePath -ErrorAction Stop
                }
                Catch {
                    $pathAccessible = [string]$error[0].Exception.InnerException.Message
                }

                # Create an object for the table row and add it to the overall array
                $gpoTableRow = New-Object System.Object
                $gpoTableRow | Add-Member -MemberType NoteProperty -Name 'GPOName' -Value $gpoName
                $gpoTableRow | Add-Member -MemberType NoteProperty -Name 'GPOLinkedTo' -Value $gpoLinkedTo
                $gpoTableRow | Add-Member -MemberType NoteProperty -Name 'DriveLetter' -Value $mappedLetter.ToLower()
                $gpoTableRow | Add-Member -MemberType NoteProperty -Name 'MappedPath' -Value $sharePath.ToLower()
                $gpoTableRow | Add-Member -MemberType NoteProperty -Name 'MappedToAnAlias' -Value $isAnAlias
                $gpoTableRow | Add-Member -MemberType NoteProperty -Name 'ServerFQDN' -Value $serverName
                $gpoTableRow | Add-Member -MemberType NoteProperty -Name 'ServerIP' -Value $serverIP
                $gpoTableRow | Add-Member -MemberType NoteProperty -Name 'ServerOnline' -Value $serverOnline
                $gpoTableRow | Add-Member -MemberType NoteProperty -Name 'PathAccessible' -Value $pathAccessible
                $gpoTable += $gpoTableRow
            }
        }
    }
}

# Export the final table of results to a CSV file
$gpoTable | Export-Csv -Path $outputFile -NoTypeInformation

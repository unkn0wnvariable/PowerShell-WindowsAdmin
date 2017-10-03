# Get DNS Settings from AD computers

$searchBase = ''

Import-Module ActiveDirectory

$computers = Get-ADComputer -Filter * -Properties OperatingSystem -SearchBase $searchBase | Where {$_.OperatingSystem -match 'Windows'}

$outputResults = @()

ForEach ($computer in $computers) {
    Write-Progress -Activity "Getting details from.." -status $computer.Name -percentComplete ($computers.IndexOf($computer) / $computers.Count * 100)

    If (Test-Connection -ComputerName $computer.DNSHostName -Count 1 -Quiet -ErrorAction SilentlyContinue) {
        Try {
            $ethConnections = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $computer.DNSHostName -ErrorAction Stop -Filter IPEnabled=TRUE | Where {$_.Description -notmatch 'miniport|ISATAP|Teredo|Async'}

            ForEach ($ethConnection in $ethConnections) {
                $outputObj = New-Object -Type PSObject
                $outputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $computer.Name
                $outputObj | Add-Member -MemberType NoteProperty -Name DHCPEnabled -Value $ethConnection.DHCPEnabled
                $outputObj | Add-Member -MemberType NoteProperty -Name DNSDomainSuffixes -Value ($ethConnection.DNSDomainSuffixSearchOrder -join '; ')
                $outputObj | Add-Member -MemberType NoteProperty -Name DNSServers -Value ($ethConnection.DNSServerSearchOrder -join '; ')
                If (!($ethConnection.WINSPrimaryServer) -or !($ethConnection.WINSSecondaryServer)) {
                    $outputObj | Add-Member -MemberType NoteProperty -Name WINSServers -Value ($ethConnection.WINSPrimaryServer,$ethConnection.WINSSecondaryServer -join '')
                }
                Else {
                    $outputObj | Add-Member -MemberType NoteProperty -Name WINSServers -Value ($ethConnection.WINSPrimaryServer,$ethConnection.WINSSecondaryServer -join '; ')
                }
                $outputResults += $outputObj
            }
        }
        Catch {
            $outputObj = New-Object -Type PSObject
            $outputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $computer.Name
            $outputObj | Add-Member -MemberType NoteProperty -Name DHCPEnabled -Value ''
            $outputObj | Add-Member -MemberType NoteProperty -Name DNSDomainSuffixes -Value ''
            $outputObj | Add-Member -MemberType NoteProperty -Name DNSServers -Value ''
            $outputObj | Add-Member -MemberType NoteProperty -Name WINSServers -Value ''
            $outputResults += $outputObj
        }
    }
    Else {
        $outputObj = New-Object -Type PSObject
        $outputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $computer.Name
        $outputObj | Add-Member -MemberType NoteProperty -Name DHCPEnabled -Value ''
        $outputObj | Add-Member -MemberType NoteProperty -Name DNSDomainSuffixes -Value ''
        $outputObj | Add-Member -MemberType NoteProperty -Name DNSServers -Value ''
        $outputObj | Add-Member -MemberType NoteProperty -Name WINSServers -Value ''
        $outputResults += $outputObj
    }
    $outputObj | FT
}

$outputResults | FT

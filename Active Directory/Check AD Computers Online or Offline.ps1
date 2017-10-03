# Check if AD Computers are Online or Offline

$searchBase = ''

If (!($searchBase)) {
    $computers = Get-ADComputer -Filter * -Properties Description,OperatingSystem,CanonicalName,LastLogonDate,whenCreated
}
Else {
    $computers = Get-ADComputer -Filter * -Properties Description,OperatingSystem,CanonicalName,LastLogonDate,whenCreated -SearchBase $searchBase
}

$outputResults = @()

ForEach ($computer in $computers) {
    Write-Progress -Activity "Testing connection to.." -status $computer.Name -percentComplete ($computers.IndexOf($computer) / $computers.Count * 100)

    $outputObj = New-Object -Type PSObject
    $outputObj | Add-Member -MemberType NoteProperty -Name 'ComputerName' -Value $computer.Name

    $hostAvailable = Test-Connection -ComputerName $computer.DNSHostName -Count 1 -Quiet -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

    If (!($hostAvailable)) {
        $hostAvailable = Test-Connection -ComputerName $computer.DNSHostName -Count 2 -Quiet -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    
    If ($hostAvailable) {
        $outputObj | Add-Member -MemberType NoteProperty -Name 'Status' -Value 'Online'
    }
    Else {
        $outputObj | Add-Member -MemberType NoteProperty -Name 'Status' -Value 'Offline'
    }

    $outputObj | Add-Member -MemberType NoteProperty -Name 'Description' -Value $computer.Description
    $outputObj | Add-Member -MemberType NoteProperty -Name 'OperatingSystem' -Value $computer.OperatingSystem
    $outputObj | Add-Member -MemberType NoteProperty -Name 'CanonicalName' -Value $computer.CanonicalName
    $outputObj | Add-Member -MemberType NoteProperty -Name 'LastLogonDate' -Value $computer.LastLogonDate
    $outputObj | Add-Member -MemberType NoteProperty -Name 'whenCreated' -Value $computer.whenCreated
    $outputResults += $outputObj
    $outputObj
}

$outputResults | Export-Csv -Path 'C:\Temp\AD Online Offline.csv' -NoTypeInformation

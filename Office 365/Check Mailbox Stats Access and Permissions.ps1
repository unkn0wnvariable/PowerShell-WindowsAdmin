# Script to get details for a list of mailboxes and save that out to a CSV file

# File containing the list of mailboxes
$inputFile = 'C:\Temp\MailboxList.txt'

# File to save the results to
$outputFile = 'C:\Temp\SharedMailboxes.csv'

# Check input file exists, if not end the script.
If (!(Test-Path $inputFile)) {
    Write-Host 'Input file does not exist.'
    Break
}

# Check output folder exists and create it if it doesn't
$outputPath = (Split-Path -Path $outputFile)
If (!(Test-Path -Path $outputPath)) {New-Item -Path $outputFolder -ItemType Directory}

# If output file already exists, delete it.
If (Test-Path -Path $outputFile) {Remove-Item -Path $outputFile}

# Establish a session to Exchange Online
$credential = Get-Credential -Message 'Enter your Exchange Online administrator credentials'
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri 'https://outlook.office365.com/powershell-liveid/' -Credential $credential -Authentication Basic -AllowRedirection
Import-PSSession -Session $exchangeSession

# Get the list of mailboxes from the file
$mailboxes = Get-Content -Path $inputFile

# Initialise the results table
$mailboxesTable = @()

# Iterate through the mailboxes from the file and show a progress bar as we go.
ForEach ($mailbox in $mailboxes) {
    Write-Progress -Activity 'Checking..' -status $mailbox -percentComplete ($mailboxes.IndexOf($mailbox) / $mailboxes.Count * 100)

    # Get the statistics for the mailbox.
    $mailboxStats = ''
    $mailboxStats = Get-MailboxStatistics -Identity $mailbox -ErrorAction SilentlyContinue -

    # If mailboxStats is blank then mailbox doesn't exist, so that entry can be skipped. For all others get the mailbox permissions and build the output table.
    If ($mailboxStats -ne $null) {
        # Get permit permissions for users where the username has an @ in it, this filters out all the system permissions.
        $usersWithAccess = (Get-MailboxPermission -Identity $mailbox | Where-Object -Property {($_.User -like '*@*') -and ($_.Deny -ne 'False')}).User -join '; '

        $tableRow = New-Object System.Object
        $tableRow | Add-Member -MemberType NoteProperty -Name 'MailboxUPN' -Value $mailbox
        $tableRow | Add-Member -MemberType NoteProperty -Name 'MailboxType' -Value $mailboxStats.MailboxTypeDetail
        $tableRow | Add-Member -MemberType NoteProperty -Name 'ItemCount' -Value $mailboxStats.ItemCount
        $tableRow | Add-Member -MemberType NoteProperty -Name 'TotalItemSize' -Value $mailboxStats.TotalItemSize
        $tableRow | Add-Member -MemberType NoteProperty -Name 'LastLogonTime' -Value $mailboxStats.LastLogonTime
        $tableRow | Add-Member -MemberType NoteProperty -Name 'UsersWithAccess' -Value $usersWithAccess
        $mailboxesTable += $tableRow
    }
}

# Output the final table of results to a file.
$mailboxesTable | Export-Csv -Path $outputFile -NoTypeInformation

# End the Exchange Online session
Remove-PSSession -Session $exchangeSession

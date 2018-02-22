# Script to get details for a list of groups and save that out to a CSV file
#

# File containing the list of mailboxes
$inputFile = "C:\Temp\GroupsList.txt"

# File to save the results to
$outputFile = "C:\Temp\GroupDetails.csv"

# Check input file exists, if not end the script.
If (!(Test-Path $inputFile)) {
    Write-Host "Input file does not exist."
    Break
}

# Check output folder exists and create it if it doesn't
$outputPath = (Split-Path -Path $outputFile)
If (!(Test-Path -Path $outputPath)) {
	New-Item -Path $outputFolder -ItemType Directory
}

# If output file already exists, delete it.
If (Test-Path -Path $outputFile) {
	Remove-Item -Path $outputFile
}

# Load AD module
Import-Module ActiveDirectory

# Establish a session to Exchange Online
$credential = Get-Credential -Message 'Enter your Exchange Online administrator credentials'
$sessionOptions = New-PSSessionOption -ProxyAccessType IEConfig
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri 'https://outlook.office365.com/powershell-liveid/' -Credential $credential -Authentication Basic -AllowRedirection -SessionOption $sessionOptions
Import-PSSession $exchangeSession

# Get the list of groups from the file
$groups = Get-Content -Path $inputFile

# Initialise the results table
$groupsTable = @()

# Get details for the groups and build an array of objects
ForEach ($group in $groups) {
    Write-Progress -Activity "Checking.." -status $group -percentComplete ($groups.IndexOf($group) / $groups.Count * 100)

    # Get group details
    $groupDetails = Get-ADGroup -Identity $group -Properties Name,mail,whenCreated,whenChanged,Members
    $groupMembers = $groupDetails.Members | ForEach-Object{$_.Split('=,')[1]}

    # Build the object for the results and add it to the array
    $tableRow = New-Object System.Object
    $tableRow | Add-Member -MemberType NoteProperty -Name 'DisplayName' -Value $groupDetails.Name
    $tableRow | Add-Member -MemberType NoteProperty -Name 'PrimarySmtpAddress' -Value $groupDetails.mail
    $tableRow | Add-Member -MemberType NoteProperty -Name 'WhenCreated' -Value $groupDetails.whenCreated
    $tableRow | Add-Member -MemberType NoteProperty -Name 'whenChanged' -Value $groupDetails.whenChanged
    $tableRow | Add-Member -MemberType NoteProperty -Name 'Members' -Value ($groupMembers -join '; ')
    $groupsTable += $tableRow
}

# Write results out to CSV file
$groupsTable | Export-Csv -Path $outputFile -NoTypeInformation

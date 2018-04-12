# Script to get details for a list of groups and save that out to a CSV file
#

# File containing the list of mailboxes
$inputFile = "C:\Temp\GroupsList.txt"

# File to save the results to
$outputFile = "C:\Temp\GroupDetails.csv"

# Try to get the list of groups from the file
$groups = Get-Content -Path $inputFile -ErrorAction:Stop

# Check output folder exists and create it if it doesn't
$outputPath = (Split-Path -Path $outputFile)
If (!(Test-Path -Path $outputPath)) {
	New-Item -Path $outputPath -ItemType Directory
}

# If path exists, chech if output file exists and delete it.
ElseIf (Test-Path -Path $outputFile) {
	Remove-Item -Path $outputFile
}

# Load AD module
Import-Module ActiveDirectory

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

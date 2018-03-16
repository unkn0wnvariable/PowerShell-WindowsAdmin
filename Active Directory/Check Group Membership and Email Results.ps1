# Script to monitor the members of an Active Directory group and email the result out.
#
#
# Note: I'm not using SMTP credentials because our SMTP server uses client ACLs, if you're using a server
# which requires a username and password then the script will need to be modified.
#

# Which group do we want to monitor?
$groupName = 'Example Group'

# Who do we want to send them emails to?
$emailTo = 'someone@example.com'

# Who do we want the emails to be from?
# This can either just be an email address or in the format 'Name <address>' to show a friendly name in email clients.
$emailFrom = 'Group Monitoring <someone-else@example.com>'

# What is the FQDN of the SMTP server to use?
$smtpServer = 'smtp.example.com'

# What should the email subject be?
$emailSubject = $groupName + ' Membership Report'

# Set the email encoding
$emailEncoding = 'utf8'

# Set the email body to be sent as HTML
$emailAsHtml = $true

# Location of the file to save previous run data to
$previousRunFile = $env:TEMP + '\' + $groupName + ' Group Members.txt'

# Get the group memebers recursively so we include members of member groups, also sort them alphabetically and uniquely
$groupMembers = (Get-ADGroup -Identity $groupName | Get-ADGroupMember -Recursive).Name | Sort-Object -Unique

# Set send email to false, we'll change it if there's anything to send
$sendEmail = $false

# If the file from a previous run exists then compile a list of changes, if not send all members
If (Test-Path $previousRunFile) {
    # Comparative Run

    # Clear variables
    $emailBody = ''
    $addedAccounts = ''
    $removedAccounts = ''

    # Get previous run list from file
    $previousGroupMembers = Get-Content -Path $previousRunFile

    # Check for accounts that have been added to the group
    ForEach ($groupMember in $groupMembers) {
        If ($groupMember -notin $previousGroupMembers) {
            $addedAccounts += $groupMember + '<br>'
        }
    }

    # Check for accounts that have been remove from the group
    ForEach ($previousGroupMember in $previousGroupMembers) {
        If ($previousGroupMember -notin $groupMembers) {
            $removedAccounts += $previousGroupMember + '<br>'
        }
    }

    # If accounts added, add to body and set sendEmail to true
    If ($addedAccounts -ne '') {
        $emailBody = 'Members added to group ' + $groupName + ':<br><br>' + $addedAccounts
        $sendEmail = $true
    }

    # If accounts removed, add to body and set sendEmail to true
    If ($removedAccounts -ne '') {
        $emailBody = 'Members removed from group ' + $groupName + ':<br><br>' + $removedAccounts
        $sendEmail = $true
    }
}
Else {
    # First Run

    # Add note about missing file to email body
    $emailBody = '<b>Previous run file ' + $previousRunFile + ' not found.</b><br><br>'

    # Add full user list to body
    $emailBody += 'All members of group ' + $groupName + ':<br><br>'
    ForEach ($groupMember in $groupMembers) {
        $emailBody += $groupMember + '<br>'
    }

    # Set sendEmail to true
    $sendEmail = $true
}

# Write out the current members list to file
$groupMembers | Out-File $previousRunFile

If ($sendEmail) {
    $emailArguments = @{
        To = $emailTo
        From = $emailFrom
        Subject = $emailSubject
        Body = $emailBody
        SMTPServer = $smtpServer
        Encoding = $emailEncoding
        BodyAsHtml = $emailAsHtml
    }

    Send-MailMessage @emailArguments
}

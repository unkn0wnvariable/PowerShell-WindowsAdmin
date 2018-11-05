# Script to monitor one of more disabled accounts and send an email if they are re-enabled.
#
# Note: I'm not using SMTP credentials because our SMTP server uses client ACLs, if you're using a server
# which requires a username and password then the script will need to be modified.
#

# Which accounts (one or more) do we want to monitor?
$monitoredAccounts = @('account1','account2')

# Who do we want to send the emails to?
$emailTo = 'reporting@example.domain'

# Who do we want the emails to be from?
# This can either just be an email address or in the format 'Name <address>' to show a friendly name in email clients.
$emailFrom = 'AD Account Monitoring <noreply@example.domain>'

# What should the email subject be?
$emailSubject = 'Monitored Account(s) Re-enabled'

# Email Header
$emailHeader = 'The following monitored accounts have been re-enabled:'

# Set the email encoding
$emailEncoding = 'utf8'

# Set the email body to be sent as plain text
$emailAsHtml = $false

# What is the FQDN of the SMTP server to use?
$smtpServer = 'smtp.example.domain'

# Import required modules
Import-Module -Name Microsoft.PowerShell.Utility
Import-Module -Name ActiveDirectory

# Initialise the array to store results in
$reenabledAccounts = @()

# Check the accounts
foreach ($monitoredAccount in $monitoredAccounts) {
    $adAccount = Get-ADUser -Identity $monitoredAccount
    if ($adAccount.Enabled -ne $false) {
        $reenabledAccounts += $adAccount.Name
    }
}
    
# If re-enabled accounts were found, send email
if ($reenabledAccounts) {
    $emailBody = $emailHeader + "`n`n" + ($reenabledAccounts | Out-String)

    # Set up email parameters
    $emailArguments = @{
        'To' = $emailTo;
        'From' = $emailFrom;
        'Subject' = $emailSubject;
        'Body' = $emailBody;
        'SMTPServer' = $smtpServer;
        'Encoding' = $emailEncoding;
        'BodyAsHtml' = $emailAsHtml
    }

    # Send the email
    Send-MailMessage @emailArguments
}

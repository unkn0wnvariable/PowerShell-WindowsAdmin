# Simple script to update the AD password for the specified user account.
#
# If the existing password is known then a change can be done without needing
# administrative access, otherwise account details for an admin enabled account
# will be required.
#
# Cmdlets used require the ADDS component from RSAT to be installed.

Import-Module ActiveDirectory

$userName = Read-Host -Prompt 'Enter username to change password for'
$newPassword = Read-Host -Prompt 'Enter new password' -AsSecureString

$userDN = (Get-ADUser -Identity $userName).DistinguishedName

do {
    $passwordKnown = Read-Host -Prompt 'Do you know the existing account password? (Y/N)'
} until ($passwordKnown -match '[yY|nN]')

if ($passwordKnown -eq 'Y') {
    $oldPassword = Read-Host -Prompt 'Enter old password:' -AsSecureString
    Set-ADAccountPassword -Identity $userDN -OldPassword $oldPassword -NewPassword $newPassword
}
else {
    $adminCred = Get-Credential -Message  'Without the existing password, admin access is required. Please enter admin account credentials.'
    Set-ADAccountPassword -Identity $userDN -NewPassword $newPassword -Reset -Credential $adminCred
}

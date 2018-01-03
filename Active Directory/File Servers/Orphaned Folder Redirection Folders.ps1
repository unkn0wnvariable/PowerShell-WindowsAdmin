# Compare a list of folder redirection roots on a file server to AD accounts to find orphaned
# folders. Also compares to email addresses to find folders belonging to user's who've changed
# their name (assuming they kept the old email addresses).
#
# Some Cmdlets used require the ADDS component from RSAT to be installed.


# Set folder redirection location and AD group which contains the people who should be using it

$folderRedirectionGroup = Read-Host -Prompt 'Enter the name of the folder redirection AD group'
$folderRedirectionPath = Read-Host -Prompt 'Enter the path to the folder redirection share'

# Set files to output lists to.

$missingUsersFile = 'C:\Temp\File Server Users Not Found In AD.txt'
$notUsingThisServerFile = 'C:\Temp\File Server Users Not in Group for this Server.txt'


# Get folders within the folder redirection location

$folderRedirectionUsers = (Get-ChildItem -Path $folderRedirectionPath).Name

# Try matching the folder names to user account names and create two lists of those which
# match and those which don't.

$unmatchedUsers = @()
$matchedUsers = @()

ForEach ($user in $folderRedirectionUsers) {
    Try {
        $matchedUsers += (Get-ADUser -Identity $user).SamAccountName
    }
    Catch {
        $unmatchedUsers += $user
    }
}

# Get all users from active directory and include the proxyAddresses property.
#
# Iterate through the AD users checking to see if any of them have smtp proxy addresses
# with a name which matches a folder name.
#
# SMTP proxy addresses are in the format of smtp:username@address.com so split each one on : and @
# and pull out the second array item which will be the username part of the address.

$allADUsers = Get-ADUser -Filter * -Properties proxyAddresses

$foundUsers = @()

ForEach ($adUser in $allADUsers) {
    ForEach ($proxyAddress in $adUser.proxyAddresses) {
        ForEach ($unmatchedUser in $unmatchedUsers) {
            If ($proxyAddress -like 'smtp:*') {
                $nameFromEmail = $proxyAddress.split(':@')[1]
                If ($unmatchedUser -eq $nameFromEmail -and $nameFromEmail -notin $foundUsers) {
                    $foundUsers += $unmatchedUser
                }
            }
        }
    }
}

# Compare the list of unmatched users to the list of found users from the previous section to
# compile a list of those which were not found.

$missingUsers = @()

ForEach ($unmatchedUser in $unmatchedUsers) {
    If ($unmatchedUser -notin $foundUsers) { $missingUsers += $unmatchedUser }
}

# Output list of missing users to file.

$missingUsers | Sort-Object >> $missingUsersFile


# Create a list containing all match users and those found in the previous section.

$allExistingUsers = $matchedUsers + $foundUsers

# Get a list of who should be using this server and then check to see if the folders
# which match existing users should be on there or not. Compiling a list of those
# which are not configured to use this server.

$groupMembers = (Get-ADGroupMember -Identity $folderRedirectionGroup).SamAccountName
$notUsingThisServer = @()

ForEach ($existingUser in $allExistingUsers) {
    If ($existingUser -notin $groupMembers) {
        $notUsingThisServer += $existingUser
    }    
}

# Output to file a list of folders which corespond to users who aren't configured to use this server

$notUsingThisServer | Sort-Object >> $notUsingThisServerFile


# Uncomment to output to screen numbers of users found through the various parts of the script.

#Write-Host 'Number of users found on server:' $folderRedirectionUsers.Count
#Write-Host 'Number of users found in AD by username:' $matchedUsers.Count
#Write-Host 'Number of users not found in AD by username:' $unmatchedUsers.Count
#Write-Host 'Number of users subsequently found by proxy address:' $foundUsers.Count
#Write-Host 'Number of users not found at all:' $missingUsers.Count
#Write-Host 'Number of users with folders who aren''t configured to use this server:' $notUsingThisServer.Count
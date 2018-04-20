# Script to get all memembers of the BuiltIn/Administrators group for the current domain
# I.e.: the domain the which the machine is joined where the script is being run
#

# Get the distinguished name of the current domain
$domainDN = (Get-ADDomain).DistinguishedName

# Get the members of the Administrators group for the current domain
$builtinAdmins = ([ADSI]"LDAP://CN=Administrators,CN=Builtin,$domainDN").member

# Create a blank array
$memberUsers = @()

# Iterrate through the members identifying if they are a user or group
foreach ($member in $builtinAdmins) {
if ((Get-ADObject -Identity $member).ObjectClass -eq "group") {
        # If they are a group get the distinguished names for all members of that group, and subgroups, recursively
        $memberUsers += (Get-ADGroupMember -Identity $member -Recursive).distinguishedName
    }
    else {
        # If they are a user get the distinguished name for that user
        $memberUsers += (Get-ADUser -Identity $member).distinguishedName
    }
}

# Output the number of users found in the group and all subgroups
$memberUsers.Count

# Output a list of those users distinguished names
$memberUsers | Sort-Object -Unique

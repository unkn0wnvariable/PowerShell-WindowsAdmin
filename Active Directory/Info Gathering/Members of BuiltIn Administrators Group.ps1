# Script to get all memembers of the BuiltIn/Administrators group for the current domain
# I.e.: the domain the which the machine is joined where the script is being run
#

# Get the distinguished name of the current domain
$domainDN = (Get-ADDomain).DistinguishedName

# Get the members of the Administrators group for the current domain
$BuiltinAdmins = ([ADSI]"LDAP://CN=Administrators,CN=Builtin,$domainDN").member

# Create a blank array
$MemberUsers = @()

# Iterrate through the members identifying if they are a user or group
ForEach ($Member in $BuiltinAdmins) {
If ((Get-ADObject -Identity $Member).ObjectClass -eq "group") {
        # If they are a group get the distinguished names for all members of that group, and subgroups, recursively
        $MemberUsers += (Get-ADGroupMember -Identity $Member -Recursive).distinguishedName
    }
    Else {
        # If they are a user get the distinguished name for that user
        $MemberUsers += (Get-ADUser -Identity $Member).distinguishedName
    }
}

# Output the number of users found in the group and all subgroups
$MemberUsers.Count

# Output a list of those users distinguished names
$MemberUsers | Sort-Object -Unique

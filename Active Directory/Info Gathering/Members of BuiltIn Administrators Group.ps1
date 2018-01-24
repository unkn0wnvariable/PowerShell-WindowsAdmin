$domainDN = (Get-ADDomain).DistinguishedName

$BuiltinAdmins = ([ADSI]"LDAP://CN=Administrators,CN=Builtin,$domainDN").member

$MemberUsers = @()

ForEach ($Member in $BuiltinAdmins) {
    If ((Get-ADObject -Identity $Member).ObjectClass -eq "group") {
        $MemberUsers += (Get-ADGroupMember -Identity $Member -Recursive).distinguishedName
    }
    Else {
        $MemberUsers += (Get-ADUser -Identity $Member).distinguishedName
    }
}

$MemberUsers.Count

$MemberUsers | Sort-Object -Unique

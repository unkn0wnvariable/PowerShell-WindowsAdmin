# Convert 365 ImmutableID to AD GUID

$immutableID = Read-Host -Prompt 'Enter ImmutableID to convert to Active Directory GUID'
[GUID][System.Convert]::FromBase64String($immutableID)

# Convert AD GUID to 365 ImmutableID

$adGuid = Read-Host -Prompt 'Enter Active Directory GUID to convert to ImmutableID'
[System.Convert]::ToBase64String($adGuid.tobytearray())

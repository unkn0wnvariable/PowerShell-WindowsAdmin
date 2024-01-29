# Script to create registry entries to disable Server Manager and Windows Admin Center popup from opening automatically at logon
#

# Set existing or create new registry key to disable Server Manager open at logon for current user
if ((Get-ItemProperty -Path 'registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\ServerManager').PSObject.Properties.Name -contains 'DoNotOpenServerManagerAtLogon') {
    Set-ItemProperty -Path 'registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\ServerManager' -Name 'DoNotOpenServerManagerAtLogon' -Value 1
}
else {
    New-ItemProperty -Path 'registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\ServerManager' -PropertyType 'DWord' -Name 'DoNotOpenServerManagerAtLogon' -Value 1
}

# Set existing or create new registry key to disable Server Manager open at logon for all users
if ((Get-ItemProperty -Path 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager').PSObject.Properties.Name -contains 'DoNotOpenServerManagerAtLogon') {
    Set-ItemProperty -Path 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager' -Name 'DoNotOpenServerManagerAtLogon' -Value 1
}
else {
    New-ItemProperty -Path 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager' -PropertyType 'DWord' -Name 'DoNotOpenServerManagerAtLogon' -Value 1
}

# Set existing or create new registry key to disable Windows Admin Center popup at logon for all users
# (it doesn't seem to be necessary to set this for current user as well)
if ((Get-ItemProperty -Path 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager').PSObject.Properties.Name -contains 'DoNotPopWACConsoleAtSMLaunch') {
    Set-ItemProperty -Path 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager' -Name 'DoNotPopWACConsoleAtSMLaunch' -Value 1
}
else {
    New-ItemProperty -Path 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager' -PropertyType 'DWord' -Name 'DoNotPopWACConsoleAtSMLaunch' -Value 1
}

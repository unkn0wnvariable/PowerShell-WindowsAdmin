# Script to create registry entry to turn off the Shutdown Reason prompt on Windows Server
#

# Create a new registry key for the setting if it doesn't already exist
if (!(Test-Path -Path 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Reliability')) {
    New-Item -Path 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT' -Name Reliability -Force
}

# Set existing or create new registry key to turn off the shutdown reason prompt
if ((Get-ItemProperty -Path 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Reliability').PSObject.Properties.Name -contains 'ShutdownReasonOn') {
    Set-ItemProperty -Path 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Reliability' -Name 'ShutdownReasonOn' -Value 0
}
else {
    New-ItemProperty -Path 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Reliability' -PropertyType 'DWord' -Name 'ShutdownReasonOn' -Value 0
}

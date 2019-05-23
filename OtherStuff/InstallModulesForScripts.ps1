# Script to set up PowerShell and install the modules I use.
#
# This needs to be run with administrative priviledges
#

# A folder to create for temporary downloaded files.
$tempPath = 'C:\cbh09xewztcnyj3els2v\'

# The URL to the Skype Onine PowerShell Module installer download.
$skypeUrl = "https://download.microsoft.com/download/2/0/5/2050B39B-4DA5-48E0-B768-583533B42C3B/SkypeOnlinePowerShell.Exe"

# The URL to the Exchange Online ClickOnce installer download.
$exoURL = 'https://cmdletpswmodule.blob.core.windows.net/exopsmodule/Microsoft.Online.CSE.PSModule.Client.application'

# Set the execution process to allow remotely signed scripts.
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Confirm:$false -Force

# Install NuGet package provider and mark PSGallery as trusted.
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Install modules available from PSGallery.
Install-Module -Name Az
Install-Module -Name AzureAD
Install-Module -Name Microsoft.Online.SharePoint.PowerShell
Install-Module -Name VMware.PowerCLI

# If the temp folder doesn't exist then create it, make a note whether we created it or not.
if (!(Test-Path -Path $tempPath)) {
    New-Item -Path $tempPath -ItemType Directory
    $newFolderCreated = $true
}
else {
    $newFolderCreated = $false
}

# Download and install the Skype Online PS module.
$skypePath = $tempPath + 'SkypeOnlinePowerShell.Exe'
Invoke-WebRequest -Uri $skypeUrl -OutFile $skypePath
Start-Process -Filepath $skypePath
Remove-Item -Path $skypePath

# Remove the temp folder if we created it.
if ($newFolderCreated) {
    Remove-Item -Path $tempPath
}

# Open Internet Explorer and trigger the EXO PS ClickOnce installer.
Start-Process -FilePath 'iexplore.exe' -ArgumentList $exoURL

# Write a bit of post install stuff to the screen.
Write-Output -InputObject ('It may be necessary to set up winrm, this can be done by running the following commands in an administrative command prompt:')
Write-Output -InputObject ('winrm quickconfig')
Write-Output -InputObject ('winrm set winrm/config/client/auth@{Basic="true"}')

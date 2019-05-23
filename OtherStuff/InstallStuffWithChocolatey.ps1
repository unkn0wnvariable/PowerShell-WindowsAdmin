# Script to install Chocolatey and then install a bunch of stuff with it
#
# This needs to be run with administrative priviledges
#

$appsToInstall = @(
    'awscli',
    'azure-cli',
    'caffeine',
    'chocolateygui',
    'docker-kitematic',
    'git',
    'openssh',
    'OpenSSL.Light',
    'packer',
    'pdk',
    'powershell-core',
    'putty',
    'rufus',
    'sysinternals',
    'terraform',
    'vmwarevsphereclient',
    'winscp'
)

Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-Expression -Command ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

foreach ($appToInstall in $appsToInstall) {
    Invoke-Expression -Command ('choco install ' + $appToInstall)
}

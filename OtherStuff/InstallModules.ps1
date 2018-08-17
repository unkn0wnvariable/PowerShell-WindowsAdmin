# Testing creating a script to setup pre-reqs for my other scripts...
#

Set-ExecutionPolicy -ExecutionPolicy:RemoteSigned

Install-Module -Name PackageManagement
Install-Module -Name PowerShellGet -Force

$modulesList = @(
    '7Zip4PowerShell',
    'AWSPowerShell',
    'Azure',
    'AzureAD',
    'AzureRM',
    'Carbon',
    'MSOnline',
    'Posh-SSH',
    'PSKPI',
    'SpeculationControl',
    'VMware.PowerCLI'
)

$installedModules = (Get-InstalledModule).Name

foreach ($moduleName in $modulesList) {
    if ($moduleName -notin $installedModules) {
        Install-Module -Name $moduleName -Scope CurrentUser
    }
    else {
        Update-Module -Name $moduleName
    }
}

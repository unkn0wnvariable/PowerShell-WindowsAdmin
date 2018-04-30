# Office 365

**Scripting things in Office 365**

## Pre-requisites

Some Office 365 services require modules to be installed locally, whereas others use remote
PowerShell sessions.

Microsoft have instructions on how to install modules or connect to services here:
[Connect PowerShell to Office 365 Services](https://support.office.com/en-us/article/Connect-PowerShell-to-Office-365-services-06a743bb-ceb6-49a9-a61d-db4ffdf54fa6)

In addition, the services which use remote sessions will require the script execution policy within
PowerShell to be changed to RemoteSigned. This is done either globally with:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```

Or for the current user with:

`Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`


## Disclaimer

All scripts are provided as is without warranty of any kind, use them at your own risk.

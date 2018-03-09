# VMware PowerShell

**My attempts at making life with VMware that little bit easier.**


## Prerequisites

These scripts all require PowerCLI to be installed.

PowerCLI version 10 is installed using the following command in PowerShell:

`Install-Module -Name VMware.PowerCLI -Scope CurrentUser`

If you have a previous version installed, uninstall it before installing v10. You also may need -AllowClobber to overwrite existing modules.

E.g.:

`Install-Module -Name VMware.PowerCLI -Scope CurrentUser -AllowClobber`


## PowerCLI v10 Changes

### Module vs Initialization

With the release of PowerCLI v10 we are now able to import the required modules in the normal PowerShell way, e.g. `Import-Module -Name VMware.PowerCLI`, this means that the old PowerCLI initialization script no longer works and I have updated my scripts accordingly. Going forward I cannot guarantee or verify that these scripts will work in older versions of PowerCLI, even if the environment initialisation script is used first, so please use v10 or higher.

In my scripts I'm actually using `Import-Module -Name VMware.PowerCLI -Force` to make sure the correct module is loaded.

### Invalid Certificates

PowerCLI 10 changes the default behaviour for untrusted certificates from warn to fail, this means you won't be able to connect if using self-signed certificates.

This behaviour can be reverted back temporarily using:

`Set-PowerCLIConfiguration -InvalidCertificateAction Warn -Scope Session -Confirm:$false`

Or permanently using:

`Set-PowerCLIConfiguration -InvalidCertificateAction Warn -Confirm:$false`

Personally I prefer setting it to prompt, then I can make my choice on a per-server basis.

E.g.:

`Set-PowerCLIConfiguration -InvalidCertificateAction Prompt -Confirm:$false`

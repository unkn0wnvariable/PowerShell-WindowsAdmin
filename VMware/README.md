# VMware PowerShell

My attempts at making life with VMware that little bit easier.

## Prerequisites

These scripts all require PowerCLI to be installed.

PowerCLI version 10 is installed using the following command in PowerShell:

Install-Module -Name VMware.PowerCLI -Scope CurrentUser

If you have a previous version installed, uninstall it before installing v10. You also may need -AllowClobber to overwrite existing modules.

E.g.:

Install-Module -Name VMware.PowerCLI -Scope CurrentUser -AllowClobber

## SSL Changes

PowerCLI 10 changes the default behaviour for untrusted certificates from warn to fail, this means you won't be able to connect if using self-signed certificates.

This behaviour can be changed temporarily using:

Set-PowerCLIConfiguration -InvalidCertificateAction Warn -Scope Session

Or permanently using:

Set-PowerCLIConfiguration -InvalidCertificateAction Warn

## PowerCLI v10

With the release of PowerCLI v10 we are now able to import the module for use in scripts in the normal PowerShell way, this however means that older scripts which used the PowerCLI initialization script won't work.

I'm working on updating my scripts and will put a note at the start of each one which has been updated and checked.

This obviously means I'll no longer be able to confirm if they work in older versions of PowerCLI, so please use v10.

## Pre v10 PowerCLI Path Change

At some point between me beginning to write scripts, and v6.5, VMware changed the folder name of PowerCLI from vSphere PowerCLI to just PowerCLI. This means some older scripts no longer work as they can't run the ps1 file.

This can either be fixed by changing module path from:

'C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'

to:

'C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'


Or by creating a symbolic link from the old location to the new one:

mklink /D "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI" "C:\Program Files (x86)\VMware\Infrastructure\PowerCLI"


This is, of course, all now utterly irrelevant with PowerCLI v10 which does away with this initialization script entirely and uses the more conventional Import-Module approach.
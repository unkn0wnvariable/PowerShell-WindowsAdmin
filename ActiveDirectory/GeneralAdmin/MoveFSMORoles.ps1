﻿# Script to locate DC(s) currently holding the FSMO roles and move them to a new DC.
#
# Requires the Active Directory component of RSAT to be installed.
#

<#
Note: If you've configured domain hierarchy time syncing, remember to update the Windows time configuration
after moving FSMO roles, the new DC needs to be manually configured and old DC needs reverting to auto.
If this isn't done the domain time will start to drift.

Set the new PCD to sync from NTP only:
w32tm /config /manualpeerlist:"time.windows.com,0x8" /syncfromflags:manual /reliable:yes /update

Set the previous PDC to sync from domain hierarchy only:
w32tm /config /syncfromflags:domhier /update

To check the config:
w32tm /query /configuration

Default Windows Server settings:
w32tm /config /manualpeerlist:"time.windows.com,0x8" /syncfromflags:all /reliable:no /update
#>

# Import the ActiveDirectory module
Import-Module -Name ActiveDirectory

# Where are we moving the roles to?
$newDC = ''

# Get administrative level credentials for Active Directory
$adCredentials = Get-Credential -Message 'Enter your Active Directory administrator credentials'

# Get all the domain controllers
$domainControllers = Get-ADDomainController -Filter *

# Find all the FSMO roles, they're usually all on the same server unless it's a massive domain and someone has been load balancing.
$schemaMaster = ($domainControllers | Where-Object {$_.OperationMasterRoles -contains 'SchemaMaster'}).Name
$ridMaster = ($domainControllers | Where-Object {$_.OperationMasterRoles -contains 'RIDMaster'}).Name
$infrastructureMaster = ($domainControllers | Where-Object {$_.OperationMasterRoles -contains 'InfrastructureMaster'}).Name
$domainNamingMaster = ($domainControllers | Where-Object {$_.OperationMasterRoles -contains 'DomainNamingMaster'}).Name
$pdcEmulator = ($domainControllers | Where-Object {$_.OperationMasterRoles -contains 'PDCEmulator'}).Name

# Move all the FSMO roles to the new server
Move-ADDirectoryServerOperationMasterRole -Server $schemaMaster -Identity $newDC -OperationMasterRole SchemaMaster -Credential $adCredentials -Confirm:$false
Move-ADDirectoryServerOperationMasterRole -Server $ridMaster -Identity $newDC -OperationMasterRole RIDMaster -Credential $adCredentials -Confirm:$false
Move-ADDirectoryServerOperationMasterRole -Server $infrastructureMaster -Identity $newDC -OperationMasterRole InfrastructureMaster -Credential $adCredentials -Confirm:$false
Move-ADDirectoryServerOperationMasterRole -Server $domainNamingMaster -Identity $newDC -OperationMasterRole DomainNamingMaster -Credential $adCredentials -Confirm:$false
Move-ADDirectoryServerOperationMasterRole -Server $pdcEmulator -Identity $newDC -OperationMasterRole PDCEmulator -Credential $adCredentials -Confirm:$false

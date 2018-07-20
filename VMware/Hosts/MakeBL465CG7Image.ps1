# Make BL465C G7 Image.ps1

<#
This script creates a custom installation image for VMware ESXi 6 using the custom depot from HPE

The changes that are made are to add in the older Emulex v10 drivers instead of v11 (which is not working on the BL465C G7 blade)
and to remove the Melanox nmst driver which causes a conflict with the legacy Emulex drivers on boot.

HPE drivers for ESXi 6 are available from:
http://h20564.www2.hpe.com/hpsc/swd/public/readIndex?sp4ts.oid=5033633&swLangOid=8&swEnvOid=4183

Or if that link no longer works, just search for "HP NC551i Dual Port FlexFabric 10Gb Network Adapter."

The process has to be completed in two stages since the newer drivers have to be removed and then the software depot reloaded
without them before the legacy ones can be loaded in.


If upgrading from ESXi 5.5 U3 there is an additional problem in that U3 already contains the v11 Emulex drivers which won't be removed
due to being newer than those in the upgrade. Therefor an additional manual step is required before the upgrade.

Get the ESXi 5.5 drivers from here - http://h20564.www2.hpe.com/hpsc/swd/public/readIndex?sp4ts.oid=5033633&swLangOid=8&swEnvOid=4166
 
Copy those files into a datastore that can be accessed by the ESXi host, SSH onto the host and running the following commands:

esxcli software vib remove --vibname=net-mst
esxcli software vib remove --vibname=nmst

esxcli software vib install -d /vmfs/volumes/<datastore name>/ESXi55/VMW-ESX-5.5.0-be2iscsi-10.7.110.10-offline_bundle-3165354.zip
esxcli software vib install -d /vmfs/volumes/<datastore name>/ESXi55/VMW-ESX-5.5.0-lpfc-10.7.170.0-offline_bundle-3359399.zip
esxcli software vib install -d /vmfs/volumes/<datastore name>/ESXi55/VMW-ESX-5.5.0-elxnet-10.7.220.6-offline_bundle-3518767.zip

esxcli system module set --enabled=false --module=be2net
esxcli system module set --enabled=true --module=elxnet

Replacing <datastore name> with the name of the Datastore where the offline bundles for the 5.5 drivers have been uploaded.

This will remove the net-mst and nmst Melanox drivers, load the older Emulex drivers over the newer ones and finally switch from the
legacy be2net driver to the elxnet one.
 
Before beginning the location of the files and the name of the depot file will need to be set below.

The following files will also need to be present in the specified location:

VMware-ESXi-6.0.0-Update3-5050593-HPE-600.9.7.0.17-Feb2017-depot.zip (Downloaded from VMware)
VMW-ESX-6.0.0-be2iscsi-10.7.110.10-offline_bundle-3181327.zip (Downloaded from HPE)
VMW-ESX-6.0.0-elxnet-10.7.220.6-offline_bundle-3528865.zip (Downloaded from HPE)
VMW-ESX-6.0.0-lpfc-10.7.170.0-offline_bundle-3362321.zip (Downloaded from HPE)
#>

#
# Updated for PowerCLI 10
#

# Set file locations
$tempDir = "C:\Temp"
$depotFile = "VMware-ESXi-6.0.0-Update3-5050593-HPE-600.9.7.0.17-Feb2017"

# Import the PowerCLI Module
Import-Module -Name VMware.PowerCLI -Force

#################################################################
# Create temp depot with unwanted drivers removed from it.      #
#################################################################

# Load depot
Add-EsxSoftwareDepot -DepotUrl  "$tempDir\$depotFile-depot.zip"

# Get profile name (we're assumimg the HPE only contains one image) and set new profile name
$oldProfile = Get-EsxImageProfile | Select-Object -ExpandProperty Name
$newProfile = "BL465C-G7-$oldProfile"

# Clone to new image, rename and set acceptance level
New-EsxImageProfile -CloneProfile $oldProfile -Name $newProfile -Vendor "HPE (Modified)" -AcceptanceLevel PartnerSupported

# Remove Mellanox and Emulex packages in the required order
Remove-EsxSoftwarePackage -ImageProfile $newProfile -SoftwarePackage "nmst"
Remove-EsxSoftwarePackage -ImageProfile $newProfile -SoftwarePackage "net-mst"
Remove-EsxSoftwarePackage -ImageProfile $newProfile -SoftwarePackage "lpfc"
Remove-EsxSoftwarePackage -ImageProfile $newProfile -SoftwarePackage "scsi-be2iscsi"
Remove-EsxSoftwarePackage -ImageProfile $newProfile -SoftwarePackage "ima-be2iscsi"
Remove-EsxSoftwarePackage -ImageProfile $newProfile -SoftwarePackage "elxnet"

# Export to new depot
Export-EsxImageProfile -ImageProfile $newProfile -ExportToBundle -FilePath "$tempDir\Temp-BL465C-G7-$depotFile-depot.zip"

# Clear all imported depots
Get-EsxSoftwareDepot | Remove-EsxSoftwareDepot

#################################################################

#################################################################
# Load temp depot add legacy drivers and export as a new depot. #
#################################################################

# Load new depot
Add-EsxSoftwareDepot -DepotUrl "$tempDir\Temp-BL465C-G7-$depotFile-depot.zip"

# Load Emulex driver depots
Add-EsxSoftwareDepot -DepotUrl "$tempDir\VMW-ESX-6.0.0-be2iscsi-10.7.110.10-offline_bundle-3181327.zip"
Add-EsxSoftwareDepot -DepotUrl "$tempDir\VMW-ESX-6.0.0-elxnet-10.7.220.6-offline_bundle-3528865.zip"
Add-EsxSoftwareDepot -DepotUrl "$tempDir\VMW-ESX-6.0.0-lpfc-10.7.170.0-offline_bundle-3362321.zip"

# Add Emulex drivers to image profile in the required order
Add-EsxSoftwarePackage -ImageProfile $newProfile -SoftwarePackage "lpfc"
Add-EsxSoftwarePackage -ImageProfile $newProfile -SoftwarePackage "ima-be2iscsi"
Add-EsxSoftwarePackage -ImageProfile $newProfile -SoftwarePackage "scsi-be2iscsi"
Add-EsxSoftwarePackage -ImageProfile $newProfile -SoftwarePackage "elxnet"

# Export new depot
Export-EsxImageProfile -ImageProfile $newProfile -ExportToBundle -FilePath "$tempDir\BL465C-G7-$depotFile-depot.zip"

# Export to ISO
Export-EsxImageProfile -ImageProfile $newProfile -ExportToIso -FilePath "$tempDir\BL465C-G7-$depotFile.iso"

# Clear all imported depots
Get-EsxSoftwareDepot | Remove-EsxSoftwareDepot

# Delete the temp depot file
Remove-Item -Path "$tempDir\Temp-BL465C-G7-$depotFile-depot.zip"

#################################################################

# Script to detach a list of datastores and their underlying LUNs from all the hosts in vSphere


# Set stuff

# PowerCLI includes a script to check the necessary modules are installed and then load them all. There's no real point
# in replicating all that in every script I make, so lets just used it as is.
#
# This is the default location for the PowerCLI script, it should be correct unless a custom install location was used.
$initializePowerCLI = 'C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'

# The DatastoreFunctions script from VMware is required to enable functions used here.
# This is available from: https://communities.vmware.com/docs/DOC-18008
#
# Set the location you have saved the script to here
$datastoreFunctions = 'C:\Temp\DatastoreFunctions.ps1'

# Where is the file containing the list of Datastores that are to be deleted?
$datastoresList = 'C:\Temp\DatastoresToDetach.txt'


# Check Stuff

# Check PowerCLI script exists, if so run it, if not notify and terminate.
If (!(Test-Path -Path $initializePowerCLI)) {
    Write-Host -Object 'Initialize PowerCLI Environment script not found. Is PowerCLI Installed?' -ForegroundColor Red
    Break
}

# Check DatastoreFunctions script exists, if so run it, if not notify and terminate.
If (!(Test-Path -Path $datastoreFunctions)) {
    Write-Host -Object 'Datastore Functions script not found. Is the path to its location correct?' -ForegroundColor Red
    Break
}

# Check datastores list exists, if so run it, if not notify and terminate.
If (!(Test-Path -Path $datastoresList)) {
    Write-Host -Object 'Datastores list not found. Is the path to its location correct?' -ForegroundColor Red
    Break
}


# Load Stuff

# Run the Initialize PowerCLI Environment script
.$initializePowerCLI

# Run the Datastore Functions script to create the required functions
.$datastoreFunctions


# Get Stuff

# Get list of datastores to be removed
$datastoresToRemove = Get-Content -Path $datastoresList

# Get name of VI server and connect to it
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'
Connect-VIServer -Server $viServer


# Do Stuff

# Disable storage IO control on datastores
Set-Datastore -Datastore $datastoresToRemove -StorageIOControlEnabled:$false -Confirm:$false

# Unmount datastores
#
# A word of note - this is really very slow through PowerCLI as it has to be done one host at a time.
# It's much quicker to unmount from the VMware GUI which will unmount from all hosts in parallel.
#
# There are also checks which will be carried out when performing this through the GUI, which are
# bypassed when doing it through PowerCLI.
#
ForEach ($datastore in $datastoresToRemove) {
    Get-Datastore -Name $datastore | Unmount-Datastore
}

# Detach datastores
ForEach ($datastore in $datastoresToRemove) {
    Get-Datastore -Name $datastore | Detach-Datastore
}

# Disconnect from VI server
Disconnect-VIServer -Server $viServer -Confirm:$false

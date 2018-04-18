# Break down the notes on VMs into sections
#
# Written for PowerCLI 10
#

<#
The purpose of this script is to break down the notes on our VMs into the sections which we generally include and then output
them to seperate columns in a CSV file. Obviously that's quite specialist, so it's probably of more use as an example than a
use-as-is working script.

The script is looking for notes in the format of at least 4 sections, on 4 lines, called Service, Product, Owner and Description,
each seperated from their value by a colon.

If any one of those fields is missing then it'll output what it can and include the whole of the note (with new lines replaced by
a semicolon) in the description field.

Hopefully that makes sense!

The CSV output from this script can subsequently be updated and fed back into "Add Notes To VMs."
#>

# Get Credentials
$viCredential = Get-Credential -Message 'Enter credentials for VMware connection'

# Get vSphere server name
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'

# Import the PowerCLI Module and Connect
Import-Module -Name VMware.PowerCLI -Force
Connect-VIServer -Server $viServer -Credential $viCredential

# Where to save the list to
$outputfile = 'C:\Temp\VMware Guests.csv'

# Get all VMs
$vms = Get-VM -Server $viServer

# Initialise the output table
$outputTable = @()

# Build the output table from the VM list
foreach ($vm in $vms) {
    # Blank out the notes sections
    $service = ''
    $product = ''
    $owner = ''
    $description = ''

    # Break down the notes and get each section of information
    foreach ($noteSection in ($vm.notes.Split("`n"))) {
        $noteInfo = ($noteSection -split ':')
        switch ($noteInfo[0].Trim()) {
            'Service' {$service = $noteInfo[1].Trim()}
            'Product' {$product = $noteInfo[1].Trim()}
            'Owner' {$owner = $noteInfo[1].Trim()}
            'Description' {$description = $noteInfo[1].Trim()}
        }
    }

    # If any section is missing put the whole note into the description field
    if (!($service -and $product -and $owner -and $description)) {
        $description = $vm.Notes -replace '\n','; '
    }
    
    # Add an object to the output table
    $outputTable += [pscustomobject]@{
        'Name' = $vm.Name;
        'PowerState' = $vm.PowerState;
        'GuestOS' = $vm.Guest.OSFullName;
        'Service' = $service;
        'Product' = $product;
        'Owner' = $owner;
        'Description' = $description
    }
}

# Output to a CSV file
$outputTable | Export-Csv -Path $outputfile -NoTypeInformation

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

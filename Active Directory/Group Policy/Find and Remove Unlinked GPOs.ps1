# Script to find unlinked GPO's and remove them if we don't want them

# Import the GP module
Import-Module GroupPolicy

# Get all GPO's
$gpos = Get-GPO -All

# Set up the results array
$unlinkedGPOs = @()

# Get report for each GPO and add those which aren't linked to the results array
ForEach ($gpo in $gpos) {
    Write-Progress -Activity "Checking.." -status $gpo.DisplayName -percentComplete ($gpos.IndexOf($gpo) / $gpos.Count * 100)
    $gpoReport = Get-GPOReport -Name $gpo.DisplayName -ReportType xml
    If (([xml]$gpoReport).GPO.LinksTo -eq $null) {
        $unlinkedGPOs += $gpo
    }
}

# Output the results array to screen
If ($unlinkedGPOs.Count -gt 0) {
    Write-Host 'The following unlinked GPOs have been found:'
    $unlinkedGPOs | FT DisplayName,DomainName,Owner,CreationTime -AutoSize
}
Else {
    Write-Host 'No unlinked GPOs were found.'
}

# Remove the unlinked GPOs if we don't want them
If ($unlinkedGPOs.Count -gt 0) {
    $removeGPOs = Read-Host -Prompt 'Would you like to remove these GPOs? (Y/N) [N]'
    If ($removeGPOs -match '[Y|y]') {
        ForEach ($unlinkedGPO in $unlinkedGPOs) {
            Write-Host 'Removing GPO:' $unlinkedGPO.DisplayName
            Remove-GPO -Name $unlinkedGPO.DisplayName -Confirm $false
        }
    }
}

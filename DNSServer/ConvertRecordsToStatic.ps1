# Script to convert dynamic DNS records to static records in a Windows DNS server
# We're essentially just recreating the same record over the existing one
#

# Import the necessary modules
Import-Module -Name 'DnsServer', 'CimCmdlets'

# Define the variables
$server = ''
$dnsZone = ''
$searchString = ''

# Get the credentials for connecting to the DNS server
$credential = Get-Credential -Message 'Enter credentials for an account with the necessary permissions'

# Create a CIM session to the DNS server
$cimSession = New-CimSession -ComputerName $server -Credential $credential -Authentication Negotiate

# Get all the DNS records that match the search string
$dnsRecords = Get-DnsServerResourceRecord -CimSession $cimSession -ZoneName $dnsZone | Where-Object { $_.HostName -match $searchString }

# Loop through the DNS records and recreate them as static records
foreach ($dnsRecord in $dnsRecords) {
    Set-DnsServerResourceRecord -OldInputObject $dnsRecord -NewInputObject $dnsRecord -ComputerName $server -ZoneName $dnsZone
}

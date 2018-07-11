# Retrives a list of all DC's in the domain and then iterates through them clearing their DNS caches.
#
# Cmdlets used require the ADDS component from RSAT to be installed.

Get-ADDomainController -Filter * | ForEach-Object { Clear-DnsServerCache –ComputerName $_.HostName -Force }

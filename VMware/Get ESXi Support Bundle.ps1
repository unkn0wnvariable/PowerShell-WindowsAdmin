# Get support bundle from an ESXi 5.5 or newer host using HTTP request method

$esxCredential = Get-Credential -Credential 'root'

$servers = @('')

$saveToFolder = 'c:\temp\'
 
ForEach ($server in $servers) {
    $dateTime = Get-Date -UFormat '%Y-%m-%d--%H.%M'
    $source = 'https://' + $server +'/cgi-bin/vm-support.cgi'
    $destination = $saveToFolder + 'esx-' + $server + '-' + $dateTime + '.tgz'
    Invoke-WebRequest -Uri $source -OutFile $destination -Credential $esxCredential
}
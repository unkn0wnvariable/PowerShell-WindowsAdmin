Import-Module ActiveDirectory

$outputFile = 'C:\Temp\LastLogons.csv'
Out-File $outputFile -Encoding utf8 -Force

$tableHeader = 'Name,Account Name,Email Address,Last Logon Date,Last Logon Time'
Write-Output $tableHeader | Out-File $outputFile -Encoding utf8 -Append

$users = Get-ADUser -Filter '(enabled -eq $true)' -Properties lastLogon,mail

Foreach ($user in $users) {
    $lastLogonDate = [datetime]::FromFileTime($user.lastLogon).ToString('dd/MM/yyyy')
    $lastLogonTime = [datetime]::FromFileTime($user.lastLogon).ToString('HH:mm:ss')

    $output = $user.Name + ',' + $user.SamAccountName + ',' + $user.mail + ',' + $lastLogonDate + ',' + $lastLogonTime

    Write-Output $output | Out-File $outputFile -Encoding utf8 -Append
}

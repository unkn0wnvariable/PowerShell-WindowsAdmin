Import-Module ActiveDirectory

$cutOffDate = (Get-Date).AddDays('-21')

$outputFile = 'C:\Temp\OldLogons.csv'
Out-File $outputFile -Encoding utf8 -Force

$tableHeader = 'Name,SamAccountName,UserPrincipalName,EmailAddress,lastLogon'
Write-Output $tableHeader | Out-File $outputFile -Encoding utf8 -Append

$users = Get-ADUser -Filter {Enabled -eq 'True'} -Properties Name, SamAccountName, UserPrincipalName, EmailAddress, lastLogon

ForEach ($user in $users) {
    $userLastLogon = [datetime]::FromFileTimeUtc($user.lastLogon)
    If ($userLastLogon -lt $cutOffDate) {
        If ($userLastLogon -eq '01/01/1601 00:00:00') {$userLastLogon = 'Never'}
        $output = $user.Name + ',' + $user.SamAccountName + ',' + $user.UserPrincipalName + ',' + $user.EmailAddress + ',' + $userLastLogon.ToString()
        Write-Output $output | Out-File $outputFile -Encoding utf8 -Append
    }
}

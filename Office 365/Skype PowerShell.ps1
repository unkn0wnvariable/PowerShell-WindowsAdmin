# Establish a session with Skype for Business online PowerShell

$credential = Get-Credential
$session = New-CsOnlineSession -Credential $credential -Verbose
Import-PSSession $session

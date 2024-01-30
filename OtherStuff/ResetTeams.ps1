# Clearing out the MS Teams caches with PowerShell, an easy fix for when it refuses to work properly
#

# Teams Classic (cache always has the same path with this version)
Get-ChildItem -Path ($env:APPDATA + '\Microsoft\Teams\') | Remove-Item -Recurse -Force

# New Teams (we have the find the cache path now because it changes)
$newTeamsPath = (Get-ChildItem -Path ($env:LOCALAPPDATA + '\Packages\') | Where-Object -FilterScript { $_.Name -like 'MSTeams_*' }).FullName
Get-ChildItem -Path $newTeamsPath | Remove-Item -Recurse -Force

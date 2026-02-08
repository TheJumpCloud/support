$time = Get-Date -UFormat "%B_%d_%Y_%T" | ForEach-Object { $_ -replace ":", "-" }  2> $null

New-Item -Path "C:\Windows\Temp\JumpCloud_Log_$time" -ItemType Directory
Copy-Item -Path "C:\Windows\Temp\JumpCloud_AD_Integration.log" -Destination "C:\Windows\Temp\JumpCloud_Log_$time"
Copy-Item -Path "C:\Program Files\JumpCloud\AD Sync\adsync.log" -Destination "C:\Windows\Temp\JumpCloud_Log_$time"
Copy-Item -Path "C:\Program Files\JumpCloud AD Bridge\adint.config.json" -Destination "C:\Windows\Temp\JumpCloud_Log_$time"

Compress-Archive -Path "C:\Windows\Temp\JumpCloud_Log_$time" -DestinationPath "C:\Windows\Temp\JumpCloud_Log_$time.zip"
Move-Item -Path "C:\Windows\Temp\JumpCloud_Log_$time.zip" -Destination "$([Environment]::GetFolderPath('Desktop'))\JumpCloud_Log_$time.zip"
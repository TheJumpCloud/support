## Note version 1.5.0 or later of the JumpCloud Pwsh module must be installed to leverage this script.

## After running the script five CSV files will be created within the backup location directory specified.  

## Populate the below variables before running the script

$BackupLocation = "" # Enter full path to desired backup folder for backup CSV files. Example path on Mac "/Users/Buster/Backup/JCBackup"

$JumpCloudAPIKey = "" # The JumpCloud API key can be found in the admin console by selecting the drop down icon next to admin email in top right and selecting "API Settings"

## --------------- Do not modify below this line ----------

Set-Location $BackupLocation

Connect-JCOnline -JumpCloudAPIKey $JumpCloudAPIKey -force #Force parameter used to auth to JumpCloud API without update check

Get-JCBackup -All

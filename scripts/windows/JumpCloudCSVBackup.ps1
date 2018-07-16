## Note version 1.5.0 or later of the JumpCloud Pwsh module must be installed to leverage this script.

## After running the script five CSV files will be created within the current working directory where the script is run. 

## Replace the text "Replace with your JumpCloud API key" with your JumpCloud API key before running the script.   

$JumpCloudAPIKey = "Replace with your JumpCloud API key"

Connect-JCOnline -JumpCloudAPIKey $JumpCloudAPIKey -force #Force parameter used to skip module update check. 

Get-JCBackup -All

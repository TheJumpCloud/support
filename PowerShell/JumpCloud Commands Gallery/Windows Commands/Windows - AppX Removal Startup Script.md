#### Name

Windows - AppX Removal Startup Script | v1.0 JCCG

#### commandType

windows

#### Command

```
$Ps1FileName = 'AppXRemoval_Win10.ps1'

$Ps1ScriptBody = @"
# Apps to remove
`$appname = @(
'*Microsoft.BingFinance*'
'*Microsoft.SkypeApp*'
'*Twitter*'
'*Microsoft.3DBuilder*'
'*king.com.CandyCrushSodaSaga*'
'*Microsoft.BingNews*'
'*Microsoft.WindowsMaps*'
'*Microsoft.BingSports*'
'*Microsoft.Office.OneNote*'
'*Microsoft.MicrosoftSolitaireCollection*'
'*Microsoft.WindowsAlarms*'
'*Microsoft.BingWeather*'
'*Microsoft.XboxApp*'
)
# Removes the above apps
ForEach(`$app in `$appname){
    Get-AppxPackage -Name `$app | Remove-AppxPackage -ErrorAction SilentlyContinue
}

# Deletes the .bat and the .ps1  
Remove-Item -Path "`$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\startup\LogOn.bat"  -Force
Remove-Item -Path "`$env:USERPROFILE\AppData\local\AppXRemoval_Win10.ps1"  -Force
"@

$BatBody = @" 
@echo off
start Powershell.exe -executionpolicy remotesigned -windowstyle hidden -File  %userprofile%\AppData\Local\AppXRemoval_Win10.ps1 /min
"@

# Gets all of our users excluding Public user
$users = Get-ChildItem -Path "C:\Users" | ? {$_.Name -NE 'Public'} 

# Add files in all users /local and /Startup folder
foreach($user in $users){

New-Item -Path "C:\Users\$($user.name)\AppData\local" -Name $Ps1FileName  -ItemType "file" -Value $Ps1ScriptBody 

New-Item -Path "C:\Users\$($user.name)\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" -Name "LogOn.bat" -ItemType "file" -Value $BatBody

}
```

#### Description

AppX applications are installed per user on a Windows machine. This command creates a .ps1 script and .bat file within each users profile where the payload of the .ps1 script uninstalls the listed AppX packages. Admins can add or remove AppX apps for the script to uninstall by modifying the $appname array.

Find more info on removing AppX pacakages [here](https://www.pdq.com/blog/remove-appx-packages/#)

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20-%20AppX%20Removal%20Startup%20Script.md"
```

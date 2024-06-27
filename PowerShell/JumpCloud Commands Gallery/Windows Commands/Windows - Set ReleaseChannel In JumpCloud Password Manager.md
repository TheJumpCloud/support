#### Name

Windows - Set JumpCloud Password Manager's Release Channel | v1.0 JCCG

#### commandType

windows

#### Command

```
# Set $RELEASE_CHANNEL to beta OR dogfood OR public depending on your desired release channel
$RELEASE_CHANNEL = "public"

#------- Do not modify below this line ------

$FILE_PATH = "$env:APPDATA\JumpCloud Password Manager\data\daemon\releaseChannel.txt"
$directory = Split-Path $FILE_PATH
if (-not (Test-Path $directory)) {
    New-Item -ItemType Directory -Path $directory -Force
}
Set-Content -Path $FILE_PATH -Value $RELEASE_CHANNEL -NoNewline
```

#### Description

This command will set the desired release channel for JumpCloud's Password Manager in application's directory. The relesase channel options are beta, dogfood and public.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20-%20Set%20ReleaseChannel%20In%20JumpCloud%20Password%20Manager.md"
```

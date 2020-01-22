#### Name

Mac - Install Available Updates | v1.0 JCCG

#### commandType

mac

#### Command

```
softwareupdate -i -a -R
```

#### Description

Installs available updates on a Mac system, this command will restart a system if required by the macOS update. This command must be run as root to force the restart. Set the script timeout at 1800 seconds (30 mins) to prevent the command from returning a 124 timeout error, downloading updates could take longer on slower networks. Optionally, remove the '-R' to run this command without restarting.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/JvLiV'
```

#### Name

Mac - Hide Mac App | v1.0 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash
if [ $UID != 0 ]; then
  (>&2 echo "Error:  $0 must be run as root")
  exit 1
fi
defaults write /Library/LaunchAgents/com.jumpcloud.jcagent-tray Disabled -bool true
mkdir -p /opt/jc_user_ro
touch /opt/jc_user_ro/dont_show_tray_app
```

#### Description

Hides the Mac menu bar app. After running this command the menu bar app will be hidden after the next user log out and login. 

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/jccg-mac-hidemacapp '
```

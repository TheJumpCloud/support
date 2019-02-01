#### Name

Mac - Remove Daily System Restart Daemon | v1.0 JCCG

#### commandType

mac

#### Command

```
# Navigate to the /Library/LaunchDaemons folder

cd /Library/LaunchDaemons

# Unload the plist file

launchctl unload "/Library/LaunchDaemons/jumpcloud.reboot.plist"

# Delete the plist file

rm jumpcloud.reboot.plist
```

#### Description

Removes the launch daemon `jumpcloud.reboot.plist` created by the command [Mac - Schedule Daily System Restart Daemon](https://git.io/fhSkx)

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/fhSkA'
```

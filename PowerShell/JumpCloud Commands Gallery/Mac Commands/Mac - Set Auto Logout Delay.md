#### Name

Mac - Set Auto Logout Delay | v1.0 JCCG

#### commandType

mac

#### Command

```

# Update the AutoLogOutDelay Variable
# This variable is defined in seconds by displayed as a minutes in System Preferences
# The minimum number of minutes this payload can take is 5 minutes (300 seconds)
# The maximum value this payload can take is 60 minutes (3600 seconds)
# To disable this setting set the value to 0

AutoLogOutDelay='300'

#------- Do not modify below this line ------

if [ "$AutoLogOutDelay" -ge 300 -a "$AutoLogOutDelay" -le 3600 ]; then
    echo "Enabing AutoLogOutDelay"
elif [ "$AutoLogOutDelay" -eq 0 ]; then
    echo "Disabling AutoLogOutDelay"
else echo "$AutoLogOutDelay is not a valid value. Set AutoLogOutDelay to a number between 300 and 3600 or 0 to disable" exit 2; fi

sudo defaults write /Library/Preferences/.GlobalPreferences.plist com.apple.autologout.AutoLogOutDelay -int $AutoLogOutDelay
sleep 2
sudo defaults read /Library/Preferences/.GlobalPreferences.plist com.apple.autologout.AutoLogOutDelay
```

#### Description

This command will enable the macOS setting to auto log out a machine after "X" minutes of inactivity.

The input variable for this command `AutoLogOutDelay` takes in a value between 300 and 3600 seconds.
This is represented in the System Preferences pane in minutes under the tab "Security & Privacy" > "Advanced" in the field "Log out after X minutes of inactivity".

If the value specified for the `AutoLogOutDelay` is set to 0 this will disable the setting and turn off the AutoLogOutDelay setting.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/JeY0v'
```

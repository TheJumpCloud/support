#### Name

Mac - Schedule Daily System Restart Daemon | v1.0 JCCG

#### commandType

mac

#### Command

```
# Populate 'hour' and 'minute' variables before running the command
# Daemon will be run based on system time. Hours should be in 24 hour military time format.

hour='21'
minute='00'

#--------------------Do not modify below this line--------------------

# Navigate to the /Library/LaunchDaemons folder

cd /Library/LaunchDaemons

# Create the plist file

touch jumpcloud.reboot.plist

# Populate the value of the jumpcloud.reboot.plist file into the variable $plistvar

plistvar='
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>JumpCloud.system.reboot.at.'${hour}':'${minute}'</string>
        <key>ProgramArguments</key>
        <array>
                <string>reboot</string>
        </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>'${hour}'</integer>
        <key>Minute</key>
        <integer>'${minute}'</integer>
    </dict>
</dict>
</plist>
'

# Insert the contents of the $plistvar variable into  the jumpcloud.reboot.plist file

echo "$plistvar" >jumpcloud.reboot.plist

# Load the jumpcloud.reboot.plist file

launchctl load -w "/Library/LaunchDaemons/jumpcloud.reboot.plist"
```

#### Description

Uses a [launch daemon](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html) to schedule a forced daily system restart for a given time specified in the hour='' and minute='' variables. The daemon will be listed as JumpCloud.system.reboot.at.'${hour}':'${minute}' within the launch daemon list. Use the command [Mac - List All Launch Daemons.md](https://git.io/fhSkF) to see a list of all launch daemons.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/fhSkx'
```

#### Name

Mac - Set Agent Log Level to Default | v1.0 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash

# File Locations
launchDaemon="/Library/LaunchDaemons/com.jumpcloud.agentlogdefault.plist"
scriptFile="/var/tmp/jc_setAgent.sh"

# Write the daemon
cat <<EOF > $launchDaemon
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.jumpcloud.agentlogdefault</string>
	<key>ProgramArguments</key>
	<array>
		<string>/bin/bash</string>
		<string>/var/tmp/jc_setAgnet.sh</string>
	</array>
    <key>RunAtLoad</key>
	<true/>
</dict>
</plist>
EOF

# Create the script file:
cat <<'EOF' > $scriptFile
#!/bin/bash

# Sleep 10s to let wrapper command exit 0
sleep 10

# File Locations
logLevelFile="/opt/jc/loglevel.cache"
launchDaemon="/Library/LaunchDaemons/com.jumpcloud.agentlogdefault.plist"
scriptFile="/var/tmp/jc_setAgent.sh"

# Read $logLevelFile, if exists, delete
if [[ -f $logLevelFile ]]; then
    rm $logLevelFile
fi

# Restart Agent to start logging with new level
launchctl stop com.jumpcloud.darwin-agent

# Clean up after restarting agent
# Stop & Remove Daemon
# launchctl unload $launchDaemon
rm $launchDaemon
# Remove this script
rm -- "$0"
EOF

# Load the Daemon
launchctl load -w $launchDaemon

exit 0
```

#### Description

This command will set the JumpCloud Agent Log Level to the default setting. After the command is run, a launchDaemon is triggers a second script that sets the Log Level, restarts the JumpCloud Agent and removes the launchDaemon, script pair.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/jccg-Mac-Pulljcagent.log'
```

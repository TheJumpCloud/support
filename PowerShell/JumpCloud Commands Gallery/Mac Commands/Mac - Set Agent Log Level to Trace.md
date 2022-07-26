#### Name

Mac - Set Agent Log Level to Trace | v1.0 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash

# File Locations
launchDaemon="/Library/LaunchDaemons/com.jumpcloud.agentlogtrace.plist"
scriptFile="/var/tmp/jc_setAgent.sh"

# Write the daemon
cat <<EOF > $launchDaemon
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.jumpcloud.agentlogtrace</string>
	<key>ProgramArguments</key>
	<array>
		<string>/bin/bash</string>
		<string>/var/tmp/jc_setAgent.sh</string>
	</array>
    <key>RunAtLoad</key>
	<true/>
</dict>
</plist>
EOF

# Create the script file:
cat <<'EOF' > $scriptFile
#!/bin/bash

# Set Debug Level | Either "DEBUG" or "TRACE"
setLevel="TRACE"

# Sleep 10s to let wrapper command exit 0
sleep 10

# File Locations
logLevelFile="/opt/jc/loglevel.cache"
launchDaemon="/Library/LaunchDaemons/com.jumpcloud.agentlogtrace.plist"
scriptFile="/var/tmp/jc_setAgent.sh"

logLevel () {
    # Valid Log Levels
    list=("DEBUG" "TRACE")
    if [[ ${list[*]} =~ $1 ]]; then
        echo "$(date "+%Y-%m-%d %H:%M:%S"): Setting JumpCloud-Agent debug Level to $1"
printf $1 > $logLevelFile

    echo "$(date "+%Y-%m-%d %H:%M:%S"): Log Level Set to: $(cat $logLevelFile)"
    else
        echo "$(date "+%Y-%m-%d %H:%M:%S"): Error setting log level, run script with elevated permissions"
        exit 1
    fi
}

# Call LogLevel Function to set log level
logLevel $setLevel

# Restart Agent to start logging with new level
launchctl stop com.jumpcloud.darwin-agent

# Clean up after restarting agent
# Remove launchDaemon
rm $launchDaemon
# Remove this script
rm -- "$0"
EOF

# Load the Daemon
launchctl load -w $launchDaemon

exit 0
```

#### Description

This command will set the JumpCloud Agent Log Level to Trace. The log level can be set to trace by setting the `setLevel="DEBUG"` variable to `setLevel="TRACE"` After the command is run, a launchDaemon is triggered which loads a second script to set the log Level. That second script restarts the JumpCloud Agent and removes the launchDaemon and deletes itself. The launchDameon: com.jumpcloud.agentlogdefault.plist will be unloaded on system restart.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Set%20Agent%20Log%20Level%20to%20Trace.md"
```

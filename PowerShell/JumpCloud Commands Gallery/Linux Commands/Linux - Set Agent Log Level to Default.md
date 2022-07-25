#### Name

Linux - Set Agent Log Level to Debug | v1.0 JCCG

#### commandType

linux

#### Command

```
#!/bin/bash

# Check for at command, necessary to schedule the command later
dpkg -l "at" > /dev/null 2>&1
if [ $? = '1' ]; then
    echo "at command could not be found, please install 'at' package"
    exit 1
fi

scriptFile="/var/tmp/jc_setAgent.sh"

# build the script
cat <<'EOF' > $scriptFile
#!/bin/bash

# Set Debug Level | Either "DEBUG" or "TRACE"
setLevel="DEBUG"

# File Locations
logLevelFile="/opt/jc/loglevel.cache"
scriptFile="/var/tmp/jc_setAgent.sh"

# Call LogLevel Function to set log level
if [ -f "$logLevelFile" ]; then
rm $logLevelFile
fi

# Restart Agent to start logging with new level
service jcagent restart

# Remove this script
rm -- "$0"
EOF

echo "Setting JumpCloud-Agent Log Level to default settings"
at now + 1 minutes -f $scriptFile

exit 0
```

#### Description

This command will set the JumpCloud Agent Log Level to Default logging level.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Linux%20Commands/Linux%20-%20Set%20Agent%20Log%20Level%20to%20Default.md"
```

#### Name

Mac - Pull jcagent.log | v1.1 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash
agentLogFile="/var/log/jcagent.log"
echo "============================= Begin Log ==============================="
# Pull log data and echo to standard out
while IFS="" read -r line; do
    echo "$line"
done < $agentLogFile
echo "============================== End Log ================================"
```

#### Description

Pulls the JC agent log from a Mac system and prints each line to the JumpCloud command result log. This log can be saved as a .log file.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Pull%20jcagent.log.md"
```

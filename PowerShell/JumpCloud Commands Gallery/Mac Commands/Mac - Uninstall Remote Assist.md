#### Name

Mac - Uninstall Remote Assist | v1.0 JCCG

#### commandType

mac

#### Command

```
#!/usr/bin/env bash
set -euo pipefail

function get_app_pid() {
    local -r APP_NAME=$1
    ps -eo pid,comm | awk "/${APP_NAME}$/ {print \$1}"
}

function remove_app_by_name() {
    local -r APP_NAME=$1
    if PID=$(get_app_pid "${APP_NAME}") && [[ -n "${PID}" ]]; then
        kill -s TERM "${PID}"
        sleep 1
    fi

    if PID=$(get_app_pid "${APP_NAME}") && [[ -n "${PID}" ]]; then
        kill -s KILL "${PID}"
    fi
    
    sudo rm -Rdf "/Applications/$1.app"
}

# Clean up installs having legacy name
remove_app_by_name "Jumpcloud Assist App"

# Clean up installs
remove_app_by_name "JumpCloud Remote Assist"

```

#### Description

Removes the JumpCloud Remote Assist app on a Mac system.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Uninstall%20Remote%20Assist.md"
```

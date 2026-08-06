#### Name

Mac - Uninstall JumpCloud Password Manager App | v1.1.0 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash
# This command completely removes the JumpCloud Password Manager app and all related
# files for JumpCloud managed user accounts on the device (same scope as the install command).

# JumpCloud managed users list (only these accounts are uninstalled)
MANAGED_USERS_FILE="/opt/jc/managedUsers.json"
managed_usernames=()

load_managed_usernames() {
    managed_usernames=()
    if [[ ! -f "$MANAGED_USERS_FILE" ]] || [[ ! -r "$MANAGED_USERS_FILE" ]]; then
        echo "Error: Managed users file not found or not readable: $MANAGED_USERS_FILE" >&2
        return 1
    fi

    if command -v jq >/dev/null 2>&1; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -n "$line" ]] && managed_usernames+=("$line")
        done < <(jq -r '.[] | select(.username != null and .username != "") | .username' "$MANAGED_USERS_FILE" 2>/dev/null)
    else
        # Fallback without jq: extract "username":"..." (does not support escaped quotes inside usernames)
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -n "$line" ]] && managed_usernames+=("$line")
        done < <(grep -oe '"username"[[:space:]]*:[[:space:]]*"[^"]*"' "$MANAGED_USERS_FILE" 2>/dev/null | sed -E 's/^"username"[[:space:]]*:[[:space:]]*"([^"]*)".*$/\1/')
    fi

    if [[ ${#managed_usernames[@]} -eq 0 ]]; then
        echo "Error: No managed usernames could be parsed from $MANAGED_USERS_FILE" >&2
        return 1
    fi
}

is_managed_user() {
    local u="$1"
    printf '%s\n' "${managed_usernames[@]}" | grep -Fxq -- "$u"
}

list_local_users() {
    dscl . list /Users | grep -vE 'root|daemon|nobody|^_'
}

load_managed_usernames || exit 1

# Kill any existing JumpCloud Password Manager processes
killall "JumpCloud Password Manager" >/dev/null 2>&1 || true
sleep 5

remove_jcpwm_from_user() {
    local user="$1"

    echo "Cleaning JumpCloud Password Manager for user: $user"

    APP_PATH="/Users/$user/Applications/JumpCloud Password Manager.app"
    if [[ -d "$APP_PATH" ]]; then
        echo "Removing application: $APP_PATH"
        rm -rf "$APP_PATH"
    fi

    if [[ -d /Users/$user/Desktop/JumpCloud\ Password\ Manager.app ]]; then
        echo "Removing desktop alias: /Users/$user/Desktop/JumpCloud Password Manager.app"
        rm -rf "/Users/$user/Desktop/JumpCloud Password Manager.app"
    fi

    local userDataPath="/Users/$user/Library/Application Support/JumpCloud Password Manager"
    if [[ -d "$userDataPath" ]]; then
        echo "Removing user data: $userDataPath"
        rm -rf "$userDataPath"
    fi

    local logsPath="/Users/$user/Library/Logs/JumpCloud Password Manager"
    if [[ -d "$logsPath" ]]; then
        echo "Removing logs: $logsPath"
        rm -rf "$logsPath"
    fi

    local cachesPath="/Users/$user/Library/Caches/JumpCloud Password Manager"
    if [[ -d "$cachesPath" ]]; then
        echo "Removing caches: $cachesPath"
        rm -rf "$cachesPath"
    fi

    local savedStatePath="/Users/$user/Library/Saved Application State/com.jumpcloud.passwordmanager.savedState"
    if [[ -d "$savedStatePath" ]]; then
        echo "Removing saved application state: $savedStatePath"
        rm -rf "$savedStatePath"
    fi

    for sock in "/tmp/pwm_${user}.sock" "/tmp/myki-native-messaging_${user}.sock"; do
        if [[ -e "$sock" ]]; then
            echo "Removing socket: $sock"
            rm -f "$sock"
        fi
    done
}

userUninstall=false

for user in $(list_local_users)
do
    if ! is_managed_user "$user"; then
        echo "Skipping $user (not listed in $MANAGED_USERS_FILE)."
        continue
    fi
    if [[ -d /Users/$user ]]; then
        remove_jcpwm_from_user "$user"
        userUninstall=true
    fi
done

# Check if password manager is installed in /Applications; remove if we uninstalled for a managed user
if [ -d /Applications/JumpCloud\ Password\ Manager.app ] && [ $userUninstall = true ]; then
    echo "Removing machine-scoped application: /Applications/JumpCloud Password Manager.app"
    rm -rf /Applications/JumpCloud\ Password\ Manager.app
fi

for path in /tmp/JumpCloud-Password-Manager* /tmp/jcpwm* /tmp/JumpCloud\ Password\ Manager*; do
    [[ -e "$path" ]] || continue
    echo "Removing temp artifact: $path"
    rm -rf "$path"
done

for sock in /tmp/pwm_*.sock /tmp/myki-native-messaging_*.sock; do
    [[ -e "$sock" ]] || continue
    echo "Removing socket: $sock"
    rm -f "$sock"
done

echo "JumpCloud Password Manager uninstall complete."
exit 0
```

#### Description

This command completely uninstalls the JumpCloud Password Manager app for JumpCloud managed user accounts on the device—the same scope as the install command. It terminates running Password Manager processes and removes the application from `~/Applications` (and `/Applications` when applicable), desktop aliases, logs, caches, temporary files/sockets, and all user data under `~/Library/Application Support/JumpCloud Password Manager`. On slower networks, timeouts with exit code 127 can occur. Manually setting the default timeout limit to 600 seconds may be advisable.

#### _Import This Command_

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
$command = Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Uninstall%20JumpCloud%20Password%20Manager%20App.md"
Set-JCCommand -CommandID $command.id -timeout 600
```

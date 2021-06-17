#### Name

Mac - Disable Local User | v1.0 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash
################################################################################
# This script will disable the *matched* username patterns in the usersToMatch
# list variable. For Example:
# Users on the system: administrator, steve, it-staff
# usersToMatch=(admin it)
# both the administrator and it-staff would be disabled
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Test how this command will run by setting the disable variable to false. When
# set to false the script will identify users to disable and print out a list
# without disabling the accounts
################################################################################

# Settings, set true or false
disable=true
reboot=true

# Enter user(s) patterns you want to match against (user admin bobsAccount)
usersToMatch=(userToDisable anotherUserToDisable)

# Do not modify below this line
################################################################################

# regexMatchregexPattern
regexPattern=""
# build regex matching regexPattern
pos=$(( ${#usersToMatch[*]} - 1 ))
last=${usersToMatch[$pos]}
for user in ${usersToMatch[@]}; do
    # add to regexPattern
    if [[ $user == $last ]]; then
        regexPattern+="${user}[^\s]*"
    else
        regexPattern+="${user}[^\s]*|"
    fi
done

echo "Searching System for the following users: ${usersToMatch[@]}"
echo "Regex Pattern: $regexPattern"

# Get usernames on system:
allUsers=$(dscl . list /Users UniqueID | awk '$2>500{print $1}' | grep -v super.admin | grep -v _jumpcloudserviceaccount)
echo "-------------------------------------------------------------------------"
echo "Accounts on the system:"
echo "$allUsers"
echo "-------------------------------------------------------------------------"

# Try to find match:
# Case insensitive search:
# set nocasematch option
shopt -s nocasematch

foundUsers=()
for value in ${allUsers[@]}; do
    if [[ $value =~ $regexPattern ]]; then
        echo "matched $value user"
        foundUsers+=($value)
    fi
done

# unset nocasematch option
shopt -u nocasematch

echo "The Following users will be disabled: ${foundUsers[@]}"
for user in ${foundUsers[@]}; do
    if [[ $disable = true ]]; then
    echo "[status] Attempting to disable $user's login shell..."
        chsh -s /usr/bin/false $user
        if [ $? -eq 0 ]; then
            echo "[success] $user's login shell was disabled"
        else
            echo "[failure] $user's login shell could not be disabled"
        fi
    else
        echo "[status] $user's account would have been disabled"
    fi
done

if [[ $reboot = true ]]; then
    shutdown -r now
fi

```

#### Description

This command will disable the local users that match the regex pattern supplied in the 'usersToMatch' list variable. If for example, a system contains the following users:

Steve, Administrator, IT-Admin

And the usersToMatch variable is set to (admin it), both the 'Administrator' and 'IT-Admin' Account would be disabled. The Regex pattern searches usernames for partial matches.

Run this script with disable=false to test what accounts would be disabled before running disable=true. Set the reboot=true variable to reboot the system, upon next restart the disabled users will be unable to login.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/JvSeX'
```

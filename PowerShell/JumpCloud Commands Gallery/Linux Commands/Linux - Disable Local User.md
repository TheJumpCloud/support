#### Name

Linux - Disable Local User | v1.0 JCCG

#### commandType

linux

#### Command

```
#!/bin/sh
################################################################################
# This script will disable the *matched* username patterns in the usersToMatch
# list variable. For Example:
# Users on the system: administrator, steve, it-staff
# export usersToMatch="admin it"
# both the administrator and it-staff would be disabled
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Test how this command will run by setting the disable variable to false. When
# set to false the script will identify users to disable and print out a list
# without disabling the accounts
################################################################################

# Settings, set true or false
disable=true

# Enter user(s) patterns you want to match against (user admin bobsAccount)
export usersToMatch="admin it"

# Do not modify below this line
################################################################################
# last item in matched user list
LAST_ITEM="${usersToMatch##* }"
# regexMatchregexPattern
regexPattern=""

for user in $usersToMatch; do
    echo "adding $user to regex pattern"
    if [ "$user" = "$LAST_ITEM" ]; then
        regexPattern="${regexPattern:+${regexPattern}}${user}[^\s]*"
    else
        regexPattern="${regexPattern:+${regexPattern}}${user}[^\s]*|"
    fi
done

echo "Searching System for the following users: $usersToMatch"
echo "Regex Pattern: $regexPattern"

# Get usernames on system:
allUsers=$(cut -d : -f 1 /etc/passwd)

foundUsers=""
for value in $allUsers; do
    if echo "$value" | grep -iqE "$regexPattern"; then
        echo "found user $value on system"
        foundUsers="${foundUsers:+${foundUsers}}${value} "
    fi
done
loggedInUsers=$(who -u)
for user in $foundUsers; do
    echo "Disabling $user's login shell..."
    # echo "testing for $user in $loggedInUsers"
    if [ $disable = true ]; then
        if echo "$loggedInUsers" | grep -iqE "$user"; then
            echo "logging $user out of system"
            pkill -KILL -u "${user}"
        fi
        sudo usermod --expiredate 1 $user
    fi
done

```

#### Description

This command will disable the local users that match the regex pattern supplied in the 'usersToMatch' list variable. If for example, a system contains the following users:

Steve, Administrator, IT-Admin

And the usersToMatch variable is set to (admin it), both the 'Administrator' and 'IT-Admin' Account would be disabled. The Regex pattern searches usernames for partial matches.

Run this script with disable=false to test what accounts would be disabled before running disable=true.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/JnXsj'
```

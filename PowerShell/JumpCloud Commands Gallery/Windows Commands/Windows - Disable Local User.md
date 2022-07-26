#### Name

Windows - Disable Local User | v1.0 JCCG

#### commandType

windows

#### Command

```
################################################################################
# This script will disable the *matched* username patterns in the usersToMatch
# list variable. For Example:
# Users on the system: administrator, steve, it-staff
# $usersToMatch = @("admin", "it")
# both the administrator and it-staff would be disabled
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Test how this command will run by setting the disable variable to false. When
# set to false the script will identify users to disable and print out a list
# without disabling the accounts
################################################################################

# Settings, set $true or $false
$disable = $true

# Enter user(s) patterns you want to match against (user admin bobsAccount)
$usersToMatch = @("admin", "it")

# Do not modify below this line
################################################################################

$regexPattern=""
$last = [int]($usersToMatch.Length) - 1
foreach ($user in $usersToMatch) {
    Write-Host $user
    if ($user -eq $usersToMatch[$last]){
        $regexpattern += "$($user)[^\s]*"
    }
    else{
        $regexpattern += "$($user)[^\s]*|"
    }
}
Write-Host "Searching System for the following users: $usersToMatch"
Write-Host "Regex Pattern: $regexPattern"

$localUsers = Get-LocalUser
$foundUsers = @()
foreach ($username in $localUsers.name)
{
    if ($username -match $regexPattern)
    {
        # Set Selected Username Variable
        write-host "Matched $username user found"
        $foundUsers += $username
    }
}

Write-Host "The Following users will be disabled: $foundUsers"
$loggedInUsers=query user
foreach ($username in $foundUsers){
    if ($disable){
        if ($loggedInUsers -match $username) {
            Write-Host "Logging $username out of system"
            $session = quser | Where-Object { $_ -match $username }
            ## Parse the session IDs from the output
            $sessionIds = ($session -split ' +')[2]
            Write-Host "Found $sessionIds for $username on system."
            ## Loop through each session ID and pass each to the logoff command
            $sessionIds | ForEach-Object {
                Write-Host "Logging off session id [$($_)]..."
                logoff $_
            }
        }
        Disable-LocalUser -Name $username
    }
}
```

#### Description

This command will disable the local users that match the regex pattern supplied in the 'usersToMatch' list variable. If for example, a system contains the following users:

Steve, Administrator, IT-Admin

And the $usersToMatch variable is set to ("admin", "it"), both the 'Administrator' and 'IT-Admin' Account would be disabled. The Regex pattern searches usernames for partial matches.

Run this script with disable=false to test what accounts would be disabled before running disable=true.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20-%20Disable%20Local%20User.md"
```

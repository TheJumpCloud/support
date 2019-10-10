#### Name

Mac - Install AutoPkg Apps | v1.0 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash

# autopkg should be installed in /usr/local/bin
autopkg="/usr/local/bin/autopkg"

# Assuming autopkg is installed, Install standard set of applications
# Add repo definition
$autopkg repo-add https://github.com/autopkg/recipes

# autopkg install List
$autopkg install firefox.install --verbose
$autopkg install GoogleChrome.install --verbose
$autopkg install VLC.install --verbose

```

#### Description

Installs list of AutoPkg Apps - customize this script to fit your needs. If this command fails with error 124, it may have reached it's max runtime to report back to JumpCloud, the script itself may not have failed. It might be wise to increase the timeout for this command to account for application download and installation times. Run this script as a local admin, not root. 

#### Import This Command

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/JelIy'
```

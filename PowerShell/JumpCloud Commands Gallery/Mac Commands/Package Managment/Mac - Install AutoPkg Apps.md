#### Name

Mac - Install AutoPkg Apps | v1.0 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash

# autopkg should be installed in /usr/local/bin
autopkg="/usr/local/bin/autopkg"

# Add repo definition
$autopkg repo-add https://github.com/autopkg/recipes

# Update repo definitions uncomment to update the repo below:
# $autopkg repo-update https://github.com/autopkg/recipes

# autopkg install List
# verbose option added for better logs to JumpCloud
# $autopkg install firefox.install --verbose
# $autopkg install GoogleChrome.install --verbose
# $autopkg install VLC.install --verbose

exit 0
```

#### Description

This command installs a Firefox, Chrome and VLC using AutoPkg - customize this script to fit your needs. If this command fails with error 124, it may have reached it's max runtime to report back to JumpCloud, the script itself may not have failed. It may be necessary to increase the timeout for this command to account for application download and installation times. Run this script as a local admin, not root.

#### Import This Command

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/Je2x5'
```

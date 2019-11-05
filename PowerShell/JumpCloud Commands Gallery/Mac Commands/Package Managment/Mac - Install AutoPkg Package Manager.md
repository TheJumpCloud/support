#### Name

Mac - Install AutoPkg Package Manager | v1.0 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash

# curl AutoPkg 1.2 into /tmp/
curl -L -o /tmp/autopkg-1.2.pkg "https://github.com/autopkg/autopkg/releases/download/v1.2/autopkg-1.2.pkg" >/dev/null
# run installer command to install AutoPkg
installer -pkg /tmp/autopkg-1.2.pkg -target /

exit 0
```

#### Description

This command downloads the 1.2 version of AutoPkg from github and installs it on the local system.

#### Import This Command

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/Je2xd'
```

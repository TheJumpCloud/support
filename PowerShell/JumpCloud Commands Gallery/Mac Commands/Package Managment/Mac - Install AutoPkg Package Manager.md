#### Name

Mac - Install AutoPkg Package Manager | v1.0 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash

# Get latest pkg release url from GitHub
url=$(curl -s https://api.github.com/repos/autopkg/autopkg/releases/latest |  python -c 'import json,sys;obj=json.load(sys.stdin);print obj["assets"][0]["browser_download_url"];')

# Regex match the version from the URL
if [[ $url =~ \/v(.+)\/ ]]; then
    # echo ${BASH_REMATCH[1]} ;
    version=${BASH_REMATCH[1]}
else
    echo "Not proper format";
fi

# curl AutoPkg into /tmp/
curl -L -o /tmp/autopkg-$version.pkg $url >/dev/null
# run installer command to install AutoPkg
installer -pkg /tmp/autopkg-$version.pkg -target /
```

#### Description

This command downloads the 1.2 version of AutoPkg from github and installs it on the local system.

#### Import This Command

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/Je2xd'
```

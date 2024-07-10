#### Name

Mac - Set JumpCloud Password Manager Release Channel | v1.0 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash

# Set releaseChannel to beta OR dogfood OR public depending on your desired release channel
releaseChannel="dogfood"

#------- Do not modify below this line ------

allowed_values=("beta" "dogfood" "public")

if [[ ! " ${allowed_values[@]} " =~ " $releaseChannel " ]]; then
    echo "Error: Variable \$releaseChannel must be either 'beta', 'dogfood', or 'public'."
    exit 1
fi

for user in $(dscl . list /Users | grep -vE 'root|daemon|nobody|^_'); do
    if [[ -d /Users/$user ]]; then
        basePath="/Users/$user/Library/Application Support/JumpCloud Password Manager"

        filePath="$basePath/data/daemon/releaseChannel.txt"

        mkdir -p "$(dirname "$filePath")"

        echo -n "$releaseChannel" >"$filePath"

        sudo chown -R $user "$basePath"
    fi
done
```

#### Description

This command will set the desired release channel for JumpCloud's Password Manager in application's directory. The relesase channel options are beta, dogfood and public.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Set%20ReleaseChannel%20In%20JumpCloud%20Password%20Manager.md"
```

#### Name

Linux - Set JumpCloud Password Manager's Release Channel | v1.0 JCCG

#### commandType

linux

#### Command

```
#!/bin/bash

# Set $releaseChannel to beta OR dogfood OR public depending on your desired release channel
releaseChannel="public"

#------- Do not modify below this line ------

allowed_values=("beta" "dogfood" "public")

if [[ ! " ${allowed_values[@]} " =~ " $releaseChannel " ]]; then
    echo "Error: Variable \$releaseChannel must be either 'beta', 'dogfood', or 'public'."
    exit 1
fi

for user in $(awk -F'[/:]' '{if ($3 >= 1000 && $3 != 65534) print $1}' /etc/passwd); do
    if [[ -d /home/$user ]]; then
        basePath="/home/$user/.config/JumpCloud Password Manager"

        filePath="$basePath/data/daemon/releaseChannel.txt"

        mkdir -p "$(dirname "$filePath")"

        echo -n "$releaseChannel" >"$filePath"

        sudo chown -R $user:$user "$basePath"
    fi
done
```

#### Description

This command will set the desired release channel for JumpCloud's Password Manager in application's directory. The relesase channel options are beta, dogfood and public.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Linux%20Commands/Linux%20-%20Set%20ReleaseChannel%20In%20JumpCloud%20Password%20Manager.md"
```
#### Name

Linux - Set JumpCloud Password Manager's Release Channel | v1.0 JCCG

#### commandType

linux

#### Command

```
#!/bin/bash

# Set $RELEASE_CHANNEL to beta OR dogfood OR public ON LINE 4 depending on your desired release channel
RELEASE_CHANNEL="public"

#------- Do not modify below this line ------

FILE_PATH="$HOME/.config/JumpCloud Password Manager/data/daemon/releaseChannel.txt"
mkdir -p "$(dirname "$FILE_PATH")"
echo -n "$RELEASE_CHANNEL" > "$FILE_PATH"
```

#### Description

This command will set the desired release channel for JumpCloud's Password Manager in application's directory. The relesase channel options are beta, dogfood and public.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Linux%20Commands/Linux%20-%20Set%20ReleaseChannel%20In%20JumpCloud%20Password%20Manager.md"
```
#### Name

Mac - Set JumpCloud Password Manager's Release Channel | v1.0 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash

# Set $RELEASE_CHANNEL to beta OR dogfood OR public depending on your desired releaseChannel

RELEASE_CHANNEL="public"

# Set $TARGET_ENVIRONMENT to production OR staging OR local to target user's environment

TARGET_ENVIRONMENT="production"

#------- Do not modify below this line ------

APP_NAME="JumpCloud Password Manager"

# Function to set application's name based on environment
detect_env() {
  case "$TARGET_ENVIRONMENT" in
    "production") APP_NAME="JumpCloud Password Manager" ;;
    "staging") APP_NAME="JC Password Manager Staging" ;;
    "local") APP_NAME="JC Password Manager Local" ;;
    *) APP_NAME="JumpCloud Password Manager" ;;
  esac
}

# Function to update or create file with content
update_file() {
  FILE_PATH="$HOME/Library/Application Support/$APP_NAME/data/daemon/releaseChannel.txt"
  mkdir -p "$(dirname "$FILE_PATH")"
  echo -n "$RELEASE_CHANNEL" > "$FILE_PATH"
}

main() {
  detect_env
  update_file
}

main
```

#### Description

This command will set the desired release channel for JumpCloud's Password Manager in application's directory. The relesase channel options are beta, dogfood and public.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)


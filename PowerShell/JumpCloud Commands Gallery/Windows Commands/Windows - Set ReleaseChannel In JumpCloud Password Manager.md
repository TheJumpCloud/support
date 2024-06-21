#### Name

Windows - Set JumpCloud Password Manager's Release Channel | v1.0 JCCG

#### commandType

windows

#### Command

```
# Set $RELEASE_CHANNEL to "beta", "dogfood", or "public" depending on your desired releaseChannel

$RELEASE_CHANNEL = "public"

# Set $TARGET_ENVIRONMENT to "production", "staging", or "local" to target user's environment

$TARGET_ENVIRONMENT = "production"

#------- Do not modify below this line ------

$APP_NAME = "JumpCloud Password Manager"

# Function to set application's name
function Detect-Env {
    switch ($TARGET_ENVIRONMENT) {
        "production" { $global:APP_NAME = "JumpCloud Password Manager" }
        "staging"    { $global:APP_NAME = "JC Password Manager Staging" }
        "local"      { $global:APP_NAME = "JC Password Manager Local" }
        default     { $global:APP_NAME = "JumpCloud Password Manager" }
    }
}

# Function to update or create file content
function Update-File {
    $HOME = [System.Environment]::GetFolderPath('UserProfile')
    $FILE_PATH = "$HOME\AppData\Roaming\$global:APP_NAME\data\daemon\releaseChannel.txt"

    $dir = Split-Path $FILE_PATH
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Set-Content -Path $FILE_PATH -Value $RELEASE_CHANNEL -NoNewline
}

function Main {
    Detect-Env
    Update-File
}

Main
```

#### Description

This command will set the desired release channel for JumpCloud's Password Manager in application's directory. The relesase channel options are beta, dogfood and public.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)


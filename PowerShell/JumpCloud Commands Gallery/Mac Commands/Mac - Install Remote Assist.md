#### Name

Mac - Install Remote Assist | v1.0 JCCG

#### commandType

mac

#### Command

```
REMOTE_DMG_URL="https://cdn.awsstg.jumpcloud.com/TheJumpCloud/jumpcloud-remote-assist-agent/latest/jumpcloud-assist-app.dmg"
APP_NAME="Jumpcloud Assist App.app"
LOCAL_DMG_PATH=/tmp/jumpcloud-assist-app.dmg

curl --silent --output "$LOCAL_DMG_PATH" "$REMOTE_DMG_URL" >/dev/null
VOLUME=$(hdiutil attach "$LOCAL_DMG_PATH" | grep -Eo '(\/Volumes\/.*)')
cd "$VOLUME"
rm -rf "Applications/$APP_NAME"
cp -af "$APP_NAME" Applications
cd /
hdiutil detach "$VOLUME"
rm "$LOCAL_DMG_PATH"
```

#### Description

Downloads and installs the JumpCloud Remote Assist app on a Mac system.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'TODO'
```

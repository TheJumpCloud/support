#### Name

Mac - Install Remote Assist | v1.0 JCCG

#### commandType

mac

#### Command

```
REMOTE_DMG_URL="https://cdn.awsstg.jumpcloud.com/TheJumpCloud/jumpcloud-remote-assist-agent/latest/jumpcloud-assist-app.dmg"
APP_NAME="Jumpcloud Assist App.app"
LOCAL_DMG_PATH="/tmp/jumpcloud-assist-app.dmg"

for SIGNAL in TERM KILL; do
    PID=
    for _ in $(seq 5); do
        PID=$(launchctl list | grep com.jumpcloud.assist | cut -f1)
        if [[ "$SIGNAL" == TERM ]]; then
            break
        elif [[ -n "$PID" ]]; then
            sleep 1
        fi
    done

    if [[ -n "$PID" ]]; then
        kill -s "$SIGNAL" "$PID"
    else
        break
    fi
done

curl --silent --output "$LOCAL_DMG_PATH" "$REMOTE_DMG_URL" >/dev/null
VOLUME=$(hdiutil attach "$LOCAL_DMG_PATH" | grep -Eo '(\/Volumes\/.*)')

CODESIGN_OUT=$(codesign -dv "$VOLUME/$APP_NAME")

if !? ; then
    echo "Application lacks a valid signature, aborting installation"
    exit 1
fi

if ! echo "$CODESIGN_OUT" | grep "Authority=Developer ID Application: JUMPCLOUD INC. (N985MXSH85)"; then
    echo "Application is not signed by JumpCloud, aborting installation"
    exit 1
fi

rm -rf "/Applications/$APP_NAME"
cp -a "$VOLUME/$APP_NAME" /Applications
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

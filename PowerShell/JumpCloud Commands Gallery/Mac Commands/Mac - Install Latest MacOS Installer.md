#### Name

Mac - Install Latest MacOS Installer | v1.0 JCCG

#### commandType

mac

#### Command

```
# replace the "Install macOS Catalaina.app" text with the version cached on the target system
macosinstaller="Install macOS Catalina.app"
# change the systemGroupID to match the group used in the cache macOS installer command
systemGroupID="5e74f14e45886d2939ff2562"

if [[ -d /Applications/${macosinstaller} ]]; then
    # Parse the systemKey from the conf file.
    conf="$(cat /opt/jc/jcagent.conf)"
    regex='\"systemKey\":\"[a-zA-Z0-9]{24}\"'

    if [[ $conf =~ $regex ]]; then
        systemKey="${BASH_REMATCH[@]}"
    fi

    regex='[a-zA-Z0-9]{24}'
    if [[ $systemKey =~ $regex ]]; then
        systemID="${BASH_REMATCH[@]}"
    fi

    # Get the current time.
    now=$(date -u "+%a, %d %h %Y %H:%M:%S GMT")

    # create the string to sign from the request-line and the date
    signstr="POST /api/v2/systemgroups/${systemGroupID}/members HTTP/1.1\ndate: ${now}"

    # create the signature
    signature=$(printf "$signstr" | openssl dgst -sha256 -sign /opt/jc/client.key | openssl enc -e -a | tr -d '\n')

    curl -s \
        -X 'POST' \
        -H 'Content-Type: application/json' \
        -H 'Accept: application/json' \
        -H "Date: ${now}" \
        -H "Authorization: Signature keyId=\"system/${systemID}\",headers=\"request-line date\",algorithm=\"rsa-sha256\",signature=\"${signature}\"" \
        -d '{"op": "remove","type": "system","id": "'${systemID}'"}' \
        "https://console.jumpcloud.com/api/v2/systemgroups/${systemGroupID}/members"

    echo "JumpCloud system: ${systemID} removed from system group: ${systemGroupID}"

    # Install latest OS Installer
    '/Applications/${macosinstaller}/Contents/Resources/startosinstall' --agreetolicense --forcequitapps
else
    echo "Could not find installer"
    exit 1
fi
```

#### Description

This command installs the macOS Installer specified in the macosinstaller variable. Replace "Install macOS Catalina.app" with the name of the latest cached installer on the target system. The macosinstaller variable text should include the .app extension. Change the systemGroupID to the same group ID used in the Cache Latest MacOS Installer command. The startosinstall program within the latest OS installer is called with the --agreetolicense and --forcequitapps flags to prevent user interaction. Test that this install method works for for remote users before deploying and consider changing the startosinstall flags if user interaction is required.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/Mac%20Commands/Mac%20-%20Install%20Latest%20MacOS%20Installer.md"
```

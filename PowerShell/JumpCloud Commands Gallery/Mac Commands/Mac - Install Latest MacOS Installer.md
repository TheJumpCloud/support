#### Name

Mac - Install Latest MacOS Installer | v1.0 JCCG

#### commandType

mac

#### Command

```
# replace the "Install macOS Catalaina.app" text with the version cached on the target system
macosinstaller="Install macOS Catalina.app"

if [[ -d /Applications/$macosinstaller ]]; then
    '/Applications/$macosinstaller/Contents/Resources/startosinstall' --agreetolicense --forcequitapps --nointeraction
else
    echo "Could not find installer"
    exit 1
fi
```

#### Description

Installs the macOS Installer specified in the first variable declaration. Replace "Install macOS Catalina.app" with the name of the latest cached installer on the target system. The startosinstall program within the latest OS installer is called with the --aggreetolicense, --forcequitapps and --nointeraction flags to prevent user interaction. Test that this install method works for for remote users before deploying.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/JvLiV'
```

#### Name

Mac - Install AutoPkg Package Manager | v1.0 JCCG

#### commandType

mac

#### Command

```
curl -L -o /tmp/autopkg-1.2.pkg "https://github.com/autopkg/autopkg/releases/download/v1.2/autopkg-1.2.pkg" >/dev/null
installer -pkg /tmp/autopkg-1.2.pkg -target /

exit 0
```

#### Description

Installs AutoPkg to a mac system without user input.

#### Import This Command

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/JelTB'
```

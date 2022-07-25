#### Name

Mac - Prevent macOS Catalina install | v1.0 JCCG

#### commandType

mac

#### Command

```
softwareupdate --ignore "macOS Catalina"
```

#### Description

This command make the software update system preference pane ignore the macOS Catalina installation media. To revert this command run the command `softwareupdate --reset-ignored`


#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/Mac%20Commands/Mac%20-%20Prevent%20macOS%20Catalina%20install.md"
```

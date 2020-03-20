#### Name

Mac - Cache Latest MacOS Installer | v1.0 JCCG

#### commandType

mac

#### Command

```
softwareupdate --fetch-full-installer
```

#### Description

This command invokes the MacOS softwareupdate utility. The --fetch-full-installer flag downloads the latest Install MacOS installer available from the App Store. The --fetch-full-installer flag contains a sub-flag to specify which version of the latest Install MacOS installer to download. For example, `softwareupdate --fetch-full-installer --full-installer-version` 10.15.1 would download the 10.15.1 version of Catalina to the target system. The timeout on this command should be changed to accommodate slower networks. A timeout of 30 mins (or 1800 seconds) should suffice if running on a single system.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/JvLiV'
```

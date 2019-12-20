#### Name

Mac - Install Custom Configuration Profile | v1.0 JCCG 

#### commandType

mac

#### Command

```
# Uninstalls a profile to the selected system
# Ex. UUID should look similar to: com.github.jumpcloud.ProfileCreator.1D88852BE-24GB-43H9-A882-5E881E8C888D
UUID=""

profiles -R -p $UUID

```

#### Description

This command will uninstall a profile given a UUID, UUIDs are unique per profile and may be found either by looking at the logs using the Install Custom Configuration profiles command or by viewing the UUID with a text editor

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/jccg-mac-checkuserforsecuretoken'
```

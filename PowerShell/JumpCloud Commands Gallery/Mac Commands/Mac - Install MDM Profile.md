#### Name

Mac - Install MDM Profile | v1.0 JCCG

#### commandType

mac

#### Command

```
/usr/bin/profiles -I -F /tmp/profile_jc.mobileconfig
```

#### Description

Installs the JumpCloud MDM enrollment profile on macOS machines. **Note** your organizations enrollment profile must be uploaded to the "Files" section of the configured JumpCloud command for this command to work. 

![JC_MDM_Command](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/JC_MDM_Command.png?raw=true)

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/Jfv5e'
```

#### Name

Mac - Check User for Secure Token | JCCG v1.0

#### commandType

mac

#### Command

```
# Enter the SECURETOKEN_ADMIN_USERNAME within the "" of SECURETOKEN_ADMIN_USERNAME=""  
SECURETOKEN_ADMIN_USERNAME=""

sysadminctl interactive -secureTokenStatus $SECURETOKEN_ADMIN_USERNAME
```

#### Description

After importing this command the variable SECURETOKEN_ADMIN_USERNAME="" must populated before the command can be run. This command will verify if the user has a secure token enabled.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'Create and enter Git.io URL'
```

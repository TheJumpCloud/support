#### Name

Mac - Check User for Secure Token | v1.1 JCCG 

#### commandType

mac

#### Command

```
# Enter the username of the admin you wish to check for a secure token 
# Enter this within the "" of SECURETOKEN_ADMIN_USERNAME=""  

SECURETOKEN_ADMIN_USERNAME=""

# Enter a username of an admin user to authorize the sysadminctl command with 
# Enter this within the "" of ADMIN_USERNAME=""

ADMIN_USERNAME=""

# Enter the password of this admin user
# Enter this within the "" of ADMIN_PASSWORD=""

ADMIN_PASSWORD=""

# -------- Do not modify below this line --------

sysadminctl -adminUser $ADMIN_USERNAME -adminPassword $ADMIN_PASSWORD -secureTokenStatus $SECURETOKEN_ADMIN_USERNAME 

```

#### Description

After importing this command the variables SECURETOKEN_ADMIN_USERNAME="",ADMIN_USERNAME="", and ADMIN_PASSWORD=""  must populated before the command can be run. This command will verify if the user has a secure token enabled.

Note the same admin account can be used for the 
SECURETOKEN_ADMIN_USERNAME="" and the ADMIN_USERNAME=""

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/jccg-mac-checkuserforsecuretoken'
```

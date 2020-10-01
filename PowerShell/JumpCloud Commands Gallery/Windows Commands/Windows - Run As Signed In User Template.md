#### Name

Windows - Run As Signed In User Template | v1.1 JCCG

#### commandType

windows

#### Command

```
# If PSModule RunAsUser is not installed, install it
if ( -not (get-installedModule "RunAsUser" -ErrorAction SilentlyContinue)) {
    install-module RunAsUser -force
}
else{
    $Command = {

    #Powershell Command Goes Here.

    }
    invoke-ascurrentuser -scriptblock $Command
}
```

#### Description

This template can be modified to target a command to run as the signed in user context of a system. The Jumpcloud agent cmd runner executes as NTAuthority\System and therefore can not interact with the signed in user session on a computer. This template and accompanying Powershell Module code from https://github.com/KelvinTegelaar/RunAsUser allows the Command block to be run as the signed in user session.

Before running this command the **$Command** block must be populated.

An example of this command is if  ```C:\windows\system32\notepad.exe``` is placed in the command block and executed against a system that has a signed in user session. Notepad will launch and show up for the signed in user. This will also work if the session is locked but still signed in. It however can only work when there is one signed in session like on most workstation SKU's of Windows.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/Jv5ea'
```

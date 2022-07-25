#### Name

Windows - Run As Signed In User Template | v1.1 JCCG

#### commandType

windows

#### Command

```powershell
# If PSModule RunAsUser is not installed, install it
if ( -not (get-installedModule "RunAsUser" -ErrorAction SilentlyContinue)) {
    install-module RunAsUser -force
}

$Command = {
    #Powershell Command Goes Here.
}

invoke-ascurrentuser -scriptblock $Command
```

#### Description

This template can be modified to target a command to run as the signed in user context of a system. The Jumpcloud agent cmd runner executes as NTAuthority\System and therefore can not interact with the signed in user session on a computer. This template and accompanying Powershell Module code from https://github.com/KelvinTegelaar/RunAsUser allows the Command block to be run as the signed in user session.

Before running this command the **$Command** block must be populated.

An example of this command is if  ```C:\windows\system32\notepad.exe``` is placed in the command block and executed against a system that has a signed in user session. Notepad will launch and show up for the signed in user. This will also work if the session is locked but still signed in. It however can only work when there is one signed in session like on most workstation SKU's of Windows.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20-%20Run%20As%20Signed%20In%20User%20Template.md"
```

#### Usage Notes

From the module readme:

> When you execute invoke-ascurrentuser the command will always return the PID of the process it ran/is running in.

Unless output is explicitly redirected, the JumpCloud command_result will simply be a number representing the PID of the spawned process, not the stdout or stderr of the process. Therefore, the module maintainer recommends piping the output to a file and then grabbing the contents. Below is a full example:

```powershell
# Path to file can be anything you like, but it
# cannot contain user-scoped variables like $ENV:TEMP,
# since outside of the invoke-ascurrentuser block we have system scope
$outfile = "C:\command_results.txt"

# If $outfile does not exist, create it
if (-not(Test-Path -Path $outfile -PathType Leaf)) {
     try {
         $null = New-Item -ItemType File -Path $outfile -Force -ErrorAction Stop
     }
     catch {
         throw $_.Exception.Message
     }
 }

# If PSModule RunAsUser is not installed, install it
if ( -not (get-installedModule "RunAsUser" -ErrorAction SilentlyContinue)) {
    install-module RunAsUser -force
}

$Command = {
    # we have to specify the path here because $outfile is defined outside the command scope
    get-item HKCU:\Software\Microsoft\Windows\CurrentVersion\Run | out-file "C:\command_results.txt"
}

# assigning to null to suppress the PID from joining the results
$null = invoke-ascurrentuser -scriptblock $Command

# return the results to JC
get-content $outfile
```

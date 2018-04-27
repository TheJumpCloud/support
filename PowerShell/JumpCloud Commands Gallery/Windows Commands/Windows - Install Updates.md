#### Name

Windows - Install Updates | v1.0 JCCG

#### commandType

windows

### File

[WindowsUpdates.ps1](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/WindowsUpdates.ps1)

#### Description

After the command executes a log of the downloaded and installed updates will be present in the users C:\Windows\ directory.

This log file will be named 'JC_WinUpdate_Report_mmDDYYThhmmss' where 'mmDDYYThhmmss' corresponds to the date and time the command was run.

#### *Build This Command*

To build this command within your JumpCloud tenant follow the below steps.

##### Step 1 - Download the .ps1 file

Download the [WindowsUpdates.ps1](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/WindowsUpdates.ps1)
file to your local computer. 

Click the above link and then right click and select 'Save As'

![Save As](https://raw.githubusercontent.com/TheJumpCloud/support/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/Windows%20-%20Install%20Updates%20SaveAs.png)

** Be sure to save the file as a .ps1 file and not a .txt file **

![Save As Ps1](https://raw.githubusercontent.com/TheJumpCloud/support/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/Windows%20-%20Install%20Updates%20SaveAsPS1.png)

##### Step 2 - Create the command

Navigate to the 'Commands' section of the JumpCloud admin console. [Link](https://console.jumpcloud.com/#/commands)

Click the green (+) icon in the top left of the screen and select a command type of 'Windows'

In the name box enter
```
Windows - Install Updates | v1.0 JCCG

```

In the command box enter
```
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Windows\Temp\WindowsUpdates.ps1

```
Leave the 'Windows PowerShell' box **unchecked***

Click the 'Upload File' button and upload the file 'WindowsUpdates.ps1' which you downloaded in Step 1

Leave the Event type to 'Run Manually' and the Timeout to '120'

![Final Command](https://raw.githubusercontent.com/TheJumpCloud/support/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/Windows%20-%20Install%20Updates%20FinalCommand.png)

Save the command.


